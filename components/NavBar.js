import React from "react";
import Link from "next/link";

const NavBar = () => {
  return (
    <nav className="border-b p-6">
      <p className="text-4xl font-bold">EventTicket NFT Market</p>
      <div className="flex mt-4"> </div>
      <Link href="/">
        <a className="mr-4 text-pink-500">Home</a>
      </Link>
      <Link href="/create-item">
        <a className="mr-4 text-pink-500">Sell NFT</a>
      </Link>
      <Link href="/my-assets">
        <a className="mr-4 text-pink-500">My NFT</a>
      </Link>
      <Link href="/creator-dashboard">
        <a className="mr-4 text-pink-500">Dashboard</a>
      </Link>
    </nav>
  );
};

export default NavBar;
