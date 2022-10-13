import React, { useState, useEffect } from 'react';
import SellerCard from '../SellerCard';

export default function Sellers(props) {
    //States
    const [sellers, setSellers] = useState([]);

    const  toggleApproval = async (addr) => {
        await props.web3Data.contract.methods.toggleApproval(addr).send();
        viewSellers();
    }

    //Custom functions
    const viewSellers = async () => {
        let _sellers = await props.web3Data.contract.methods.getSellers().call();
        let newSellers = [];
        for (let seller of _sellers) {
            newSellers.push({...seller, isApproved:await props.web3Data.contract.methods.isApproved(seller.addr).call()});
        }
        setSellers(newSellers);
    };

    //Effect
    useEffect(() => {
        if (props.web3Data.wallet) {
            viewSellers();
        }
    }, [props.web3Data.wallet])

    //Component
    return (
        <div style={{ "display": "flex", "flexWrap": 'wrap' }}>
            {sellers.length > 0 ? (
                sellers.map((seller, i) => (
                    <SellerCard key={i} seller={seller} toggleApproval={toggleApproval} approvalText={seller.isApproved ? "Disapprove" : "Approve"} />
                ))
            ) : <>No seller registered</>
            }
        </div>
    );
}