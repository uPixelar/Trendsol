import React from 'react';
import './ProductCard.css';

export default function ProductCard(props) {
  let product = props.product;
  return (
    <div className="product_card">
      <p className="product_card_name">{product.name}</p>
      <div className="product_card_details">
        <p>Details: {product.details}</p>
        {product.onSale ?
          <>
            <p>Price: {product.price} Wei</p>
            <p>Stock: {product.stock}</p>
          </>
          :
          <p>Satışta değil</p>}
        <p>{Date(product.lastUpdated)}</p>
      </div>
    </div>
  );
};

