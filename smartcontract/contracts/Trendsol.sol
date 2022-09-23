// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TrendsolBase{
    //Enums

    enum SaleStatus{
        Preparing,              //Seller is preparing the product
        Shipped,                //Seller has shipped the product
        Reached,                //Shipping company delivered the product
        Completed,              //Customer confirmed the sale
        Rejected,               //Customer sent back the product
        Returned,               //Seller received the product 
        Refunded,               //Customer has took refund
        Cancelled               //Order cancelled, customer can refund
    }

    //Structs

    struct Product{
        bool onMarket;          //Has the product been added to the market?

        string name;            //Product's name/title
        string details;         //Product details

        bool onSale;            //Is product on sale
        
        uint price;             //Product price
        uint stock;             //Product stock
        uint lastUpdated;       //Product last updated
    }

    struct Sale{
        address seller;         //Seller's address
        address customer;       //Customer's address
        uint productId;         //Id of the product being bought
        SaleStatus status;      //Status of the sale
        
    }

    struct Seller{
        bool registered;        //Is seller registered to the system
        string tradeName;       //Trade name of the seller
        string contactNumber;   //Contact number of the seller
        uint approved;          //How many times did seller approved
        uint sold;              //How many sale did seller complete
    }
}

contract Trendsol is TrendsolBase{
    //Mappings

    ////Mappings > Public

    mapping(address=>Seller) public sellers;                    //Seller => Seller
    mapping(address=>mapping(uint=>Product)) public products;   //Seller => Product ID => Product

    ////Mappings > Private
    mapping(address => mapping(address => bool)) approvals;     //Person => Seller => Approved(bool)
    
    
    mapping(address=>uint) productCount;                        //Seller => Product Count (also used for id generation)
    mapping(address=>mapping(uint=>Sale)) sales;                //Seller => Sale ID => Sale
    mapping(address => mapping(uint=>Sale)) orders;             //Customer => Sale ID => Sale

    //Modifiers

    modifier MRegistered{//It increases gas cost a little bit but contract is more modular with modifiers.
        require(sellers[msg.sender].registered, "You are not registered as a seller.");
        _;
    }

    modifier MNotRegistered{
        require(!sellers[msg.sender].registered, "You are already registered as a seller.");
        _;
    }

    modifier MRegistered2(address _seller){
        require(sellers[_seller].registered, "The seller is not registered.");
        _;
    }

    //Seller

    ////Seller > Seller

    function register(string calldata _tradeName, string calldata _contactNumber) external MNotRegistered{
        Seller storage seller = sellers[msg.sender];                           //Get seller
        seller.registered = true;
        seller.tradeName = _tradeName;
        seller.contactNumber = _contactNumber;
    }

    function edit(string calldata _tradeName, string calldata _contactNumber) external MRegistered{
        Seller storage seller = sellers[msg.sender];
        seller.tradeName = _tradeName;
        seller.contactNumber = _contactNumber;
    }

    ////Seller > Product

    function addProduct(string calldata _name, string calldata _details, uint _price, uint _initialStock) external MRegistered{
        uint count = productCount[msg.sender];
        products[msg.sender][++count] = Product({
            name: _name,
            details: _details,
            price: _price,
            stock: _initialStock,
            lastUpdated: block.timestamp,
            onSale: false,
            onMarket: true
        });
        productCount[msg.sender] = count;
    }

    function toggleSale(uint _id) external MRegistered{
        Product storage product = products[msg.sender][_id];
        product.onSale = !product.onSale;
    }

    //Customer Section

    function refund(uint _id) external view{
        Sale memory sale = orders[msg.sender][_id];
        require(sale.customer == msg.sender, "You are not the customer!");
        require(sale.status == SaleStatus.Returned, "You cannot refund until the seller receives the product.");
    }

    function buy(address _seller, uint _id) external MRegistered2(_seller) view{
        Product storage product = products[_seller][_id];
        require(product.stock > 0, "Yeterli stok yok");

    }

    //Shared Section

    function toggleApproval(address _seller) external{
        require(msg.sender != _seller, "You can't approve yourself");       //Check if user approving self
        Seller storage seller = sellers[_seller];                           //Get seller
        require(seller.registered, "Seller is not registered in system");   //Check if seller registered
        bool approved = approvals[msg.sender][_seller];                     //Get if approved seller
        approvals[msg.sender][_seller] = !approved;                         //Toggle approval
        if(approved)                                                        //If approved at last state ++, else --
            seller.approved--;
        else
            seller.approved++;
        
    }

    function isApproved(address _seller) external view MRegistered2(_seller) returns(bool approved){
        return approvals[msg.sender][_seller];
    }
}