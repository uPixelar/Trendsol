// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract TrendsolBase {
    //This is the base contract holding enums, structs, constants etc.

    //Events
    event SellerRegistered(address indexed _seller)
    event ProductAdded(address indexed _seller, uint indexed _id, string _name)

    //Enums

    enum SaleStatus {
        Null, //Sale does not exist
        Preparing, //Seller is preparing the product
        Shipped, //Seller has shipped the product
        Reached, //Shipping company delivered the product
        Completed, //Customer confirmed the sale
        Rejected, //Customer sent back the product
        Returned, //Seller received the product
        Refunded, //Customer has took refund
        Cancelled //Order cancelled, customer can refund
    }

    //Structs

    struct Product {
        address seller;
        string name; //Product's name/title
        string details; //Product details
        bool onSale; //Is product on sale
        uint price; //Product price
        uint stock; //Product stock
        uint lastUpdated; //Product last updated
    }

    struct Seller {
        address addr; //Is seller registered to the system
        string tradeName; //Trade name of the seller
        string contactNumber; //Contact number of the seller
        uint approved; //How many times did seller approved
        uint sold; //How many sale did seller complete
    }

    struct Sale {
        address seller; //Seller's address
        address customer; //Customer's address
        uint productId; //Id of the product being bought
        SaleStatus status; //Status of the sale
        uint balance;
    }
}

contract Trendsol is TrendsolBase {
    //Mappings
    mapping(address => uint) public sellers; //Seller => Seller
    mapping(address => uint[]) public products; //Seller => Product ID => Product
    mapping(address => bool) public registered;

    mapping(address => mapping(address => bool)) approvals; //Person => Seller => Approved(bool)
    mapping(address => mapping(uint => Sale)) sales; //Seller => Sale ID => Sale
    mapping(address => uint) saleCount; //Seller => Sale Count (also used for id generation)
    mapping(address => mapping(uint => Sale)) orders; //Customer => Sale ID => Sale
    mapping(address => uint) orderCount; //Customer => Order Count (also used for id generation)

    Seller[] private allSellers;
    Product[] private allProducts;

    //Modifiers
    ////Modifiers are currently gas expensive, I will do experiments and fix them later...
    modifier MRegistered() {
        //It increases gas cost a little bit but contract is more modular with modifiers.
        require(registered[msg.sender], "You are not registered as a seller.");
        _;
    }

    modifier MRegistered2(address _seller) {
        require(registered[_seller], "The seller is not registered.");
        _;
    }

    modifier MNotRegistered() {
        require(
            !registered[msg.sender],
            "You are already registered as a seller."
        );
        _;
    }

    modifier MSaleExists(uint _id) {
        require(
            sales[msg.sender][_id].status != SaleStatus.Null,
            "Sale does not exist"
        );
        _;
    }

    modifier MProductValid(uint _id) {
        require(allProducts.length > _id, "Product is not valid");
        _;
    }

    //Seller
    function getSellers() external view returns (Seller[] memory) {
        return allSellers;
    }

    function getProducts() external view returns (Product[] memory) {
        return allProducts;
    }

    function countSellers() external view returns (uint256) {
        return allSellers.length;
    }

    function register(
        string calldata _tradeName,
        string calldata _contactNumber
    ) external MNotRegistered {
        registered[msg.sender] = true;
        uint id = allSellers.length;
        Seller memory seller = Seller({
            addr: msg.sender,
            tradeName: _tradeName,
            contactNumber: _contactNumber,
            approved: 0,
            sold: 0
        });

        allSellers.push(seller);
        sellers[msg.sender] = id;
        emit SellerRegistered(msg.sender)
    }

    function setTradeName(string calldata _tradeName) external MRegistered {
        allSellers[sellers[msg.sender]].tradeName = _tradeName;
    }

    function setContactNumber(string calldata _contactNumber)
        external
        MRegistered
    {
        allSellers[sellers[msg.sender]].contactNumber = _contactNumber;
    }

    ////Seller > Product

    function addProduct(
        string calldata _name,
        string calldata _details,
        uint _price,
        uint _initialStock,
        bool _onSale
    ) external MRegistered {
        uint id = allProducts.length;
        Product memory product = Product({
            seller: msg.sender,
            name: _name,
            details: _details,
            price: _price,
            stock: _initialStock,
            onSale: _onSale,
            lastUpdated: block.timestamp
        });

        allProducts.push(product);
        products[msg.sender].push(id);
        emit ProductAdded(msg.sender, id, _name)
    }

    function incStock(uint _id, uint _count)
        external
        MRegistered
        MProductValid(_id)
    {
        //Should be registered seller and product should be on market/registered
        Product storage product = allProducts[_id];
        require(product.seller == msg.sender, "You are not the seller");
        product.stock += _count;
    }

    function decrStock(uint _id, uint _count)
        external
        MRegistered
        MProductValid(_id)
    {
        //Should be registered seller and product should be on market/registered
        Product storage product = allProducts[_id];
        require(product.seller == msg.sender, "You are not the seller");
        require(product.stock >= _count, "Stock is less than decrease amount");
        product.stock -= _count;
    }

    function toggleSale(uint _id) external MRegistered MProductValid(_id) {
        Product storage product = allProducts[_id];
        product.onSale = !product.onSale;
    }

    ////Seller > Sale

    // function getSale(uint _id) external view MRegistered MSaleExists(_id) returns (address seller, address customer, uint productId, SaleStatus status){
    //     Sale memory sale = sales[msg.sender][_id];
    //     return (sale.seller, sale.customer, sale.productId, sale.status);
    // }

    //Customer Section

    // function refund(uint _id) external view{
    //     Sale memory sale = orders[msg.sender][_id];
    //     require(sale.customer == msg.sender, "You are not the customer!");
    //     require(sale.status == SaleStatus.Returned, "You cannot refund until the seller receives the product.");
    // }

    // function buy(address _seller, uint _id) payable external MRegistered2(_seller){
    //     Product storage product = products[_seller][_id];
    //     require(product.stock > 0, "No stock");
    //     require(msg.value == product.price, "Product price is not paid");
    //     Sale memory sale = Sale({
    //         seller: _seller,
    //         customer: msg.sender,
    //         productId: _id,
    //         status: SaleStatus.Preparing,
    //         balance: msg.value
    //     });
    //     product.stock--;//Decrease stock
    //     orders[msg.sender][++orderCount[msg.sender]] = sale;//Add order and increment order count of customer
    //     sales[_seller][++saleCount[_seller]] = sale;//Add sale and increment sale count of seller
    // }

    //Shared Section

    function toggleApproval(address _seller) external MRegistered2(_seller) {
        require(msg.sender != _seller, "You can't approve yourself"); //Check if user approving self
        Seller storage seller = allSellers[sellers[_seller]]; //Get seller
        bool approved = approvals[msg.sender][_seller]; //Get if approved seller
        approvals[msg.sender][_seller] = !approved; //Toggle approval
        if (approved)
            //If approved at last state ++, else --
            seller.approved--;
        else seller.approved++;
    }

    function isApproved(address _seller)
        external
        view
        MRegistered2(_seller)
        returns (bool approved)
    {
        return approvals[msg.sender][_seller];
    }
}
