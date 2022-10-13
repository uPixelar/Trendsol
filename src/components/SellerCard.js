import React from 'react';
import './SellerCard.css';



function SellerCard(props) {
  let seller = props.seller;
  return (
    <div className="seller_card">
      <p className="seller_card_name">{seller.tradeName}</p>
      <div className="seller_card_details">
        <p>Tel. No: {seller.contactNumber}</p>
        <p>Beğeniler: {seller.approved}</p>
        <p>Satışlar: {seller.sold}</p>
        <div style={{"display":"flex"}}>
          <button onClick={() => props.toggleApproval(seller.addr)}>{props.approvalText}</button>
        </div>
        <p style={{ "fontSize": "0.7em" }}>{seller.addr}</p>
      </div>


    </div>
  );
}

export default SellerCard;
