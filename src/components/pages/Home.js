import React, { useState, useEffect } from 'react';
import ProductCard from '../ProductCard';

export default function Home(props) {
    //States
    const [products, setProducts] = useState([]);

    //Custom functions
    const viewProducts = async () => {
        let products = await props.web3Data.contract.methods.getProducts().call();
        setProducts(products);
    }

    //Effect
    useEffect(() => {
        if (props.web3Data.wallet) {
            viewProducts();
        }
    }, [props.web3Data.wallet])
    
    //Component
    return (
        <>
            <div style={{"display": "flex", "flexWrap":'wrap'}}>
                {products.length > 0 ? (
                    products.map((product, i) => (
                        <ProductCard key={i} product={product} />
                    ))
                ) : <>No product submitted</>
                }
            </div>
        </>

    );
}