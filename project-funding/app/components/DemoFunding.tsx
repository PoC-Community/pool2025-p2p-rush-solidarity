import React, { useState, useEffect } from 'react';
import { Card, CardHeader, CardTitle, CardContent } from './ui/card';
import { Button } from './ui/button';
import { Input } from './ui/input';
import { Progress } from './ui/progress';
import Web3 from 'web3';
const web3 = new Web3(window.ethereum);
import { ethers } from 'ethers';

declare global {
    interface Window {
        ethereum?: any;
    }
}

const DemoFunding = () => {
  const [amount, setAmount] = useState('');
  const [fundsRaised, setFundsRaised] = useState(0);
  const [fundsNeeded, setFundsNeeded] = useState(1);
  const [progress, setProgress] = useState(0);

  const CONTRACT_ADDRESS = '0x9fE46736679d2D9a65F0992F2272dE9f3c7fa6e0';

  const connectWallet = async () => {
    if (typeof window.ethereum !== 'undefined') {
      try {
        await window.ethereum.request({ method: 'eth_requestAccounts' });
      } catch (error) {
        console.error("Error connecting wallet:", error);
      }
    }
  };

  const fetchData = async () => {
    try {
    const getFundsRaisedSignature = web3.utils.sha3('getFundsRaised()')?.slice(0, 10) || null;
    const fundsNeededSignature = web3.utils.sha3('fundsNeeded()')?.slice(0, 10) || null;
   
      const fundsResponse = await fetch('http://localhost:8545', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          jsonrpc: '2.0',
          method: 'eth_call',
          params: [{
            to: CONTRACT_ADDRESS,
            data: getFundsRaisedSignature
          }, 'latest'],
          id: 1
        })
      });
      
      const fundsResult = await fundsResponse.json();
      const fundsRaised = parseInt(fundsResult.result, 16);
      
      const goalResponse = await fetch('http://localhost:8545', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          jsonrpc: '2.0',
          method: 'eth_call',
          params: [{
            to: CONTRACT_ADDRESS,
            data: fundsNeededSignature
          }, 'latest'],
          id: 1
        })
      });
      
      const goalResult = await goalResponse.json();
      const fundsNeeded = parseInt(goalResult.result, 16);
      
      const progress = (fundsRaised / fundsNeeded) * 100;
      
      setFundsRaised(fundsRaised);
      setProgress(progress);
    } catch (error) {
      console.error("Fetch contract data error:", error);
    }
   };
  
  useEffect(() => {
    fetchData();
    const interval = setInterval(fetchData, 10000);
    return () => clearInterval(interval);
  }, []);

  const fundProject = async () => {
    if (!amount || typeof window.ethereum === 'undefined') return;
    try {
      const accounts = await window.ethereum.request({
        method: 'eth_requestAccounts'
      });
      const weiAmount = (Number(amount) * 1e18).toString(16);
      await window.ethereum.request({
        method: 'eth_sendTransaction',
        params: [{
          from: accounts[0],
          to: CONTRACT_ADDRESS,
          value: '0x' + weiAmount
        }]
      });
      await fetchData();
      setAmount('');
    } catch (error) {
      console.error("Error funding project:", error);
    }
  };

  return (
    <div className="bg-gray-400 min-h-screen">
        <Card className="w-full max-w-xl mx-auto mt-8 bg-gray-100">
        <CardHeader>
            <CardTitle>Demo Project Funding</CardTitle>
        </CardHeader>
        <CardContent className="space-y-6">
            <div>
            <p className="text-sm font-medium mb-2">Contract Address: {CONTRACT_ADDRESS}</p>
            <Button onClick={connectWallet} className="w-full">
                Connect Wallet
            </Button>
            </div>

            <div className="space-y-4">
            <div>
                <p className="text-sm mb-2">Progress: {progress.toFixed(1)}%</p>
                <Progress value={progress} className="w-full" />
            </div>
            
            <div>
                <p className="text-sm">Funds Raised: {fundsRaised.toFixed(4)} ETH</p>
                <p className="text-sm">Target: {fundsNeeded} ETH</p>
            </div>

            <div className="space-y-2">
                <Input
                type="number"
                placeholder="Amount in ETH"
                value={amount}
                onChange={(e) => setAmount(e.target.value)}
                />
                <Button onClick={fundProject} className="w-full">
                Fund Project
                </Button>
            </div>
            </div>
        </CardContent>
        </Card>
    </div>
  );
};

export default DemoFunding;