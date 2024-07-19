import { useState, useEffect } from 'react';
import { ethers } from 'ethers';
import ContributionTracker from '..//artifacts/contracts/ContributonTracker.sol/ContributionTracker.json';

export default function Home() {
  const [contribution, setContribution] = useState(0);
  const [tokenBalance, setTokenBalance] = useState(0);
  const [address, setAddress] = useState('');
  const [error, setError] = useState(null);

  useEffect(() => {
    if (!window.ethereum) return;
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();

    async function load() {
      try {
        const contractAddress = process.env.NEXT_PUBLIC_CONTRACT_ADDRESS;
        const contract = new ethers.Contract(contractAddress, ContributionTracker.abi, signer);

        const userAddress = await signer.getAddress();
        setAddress(userAddress);

        const contrib = await contract.getContribution(userAddress);
        setContribution(contrib.toString());

        const tokens = await contract.getTokenBalance(userAddress);
        setTokenBalance(tokens.toString());
      } catch (err) {
        setError(err.message);
        console.error('Error loading contract data:', err);
      }
    }

    load();
  }, []);

  async function contribute() {
    if (!window.ethereum) return;
    const provider = new ethers.providers.Web3Provider(window.ethereum);
    const signer = provider.getSigner();

    try {
      const contractAddress = process.env.NEXT_PUBLIC_CONTRACT_ADDRESS;
      const contract = new ethers.Contract(contractAddress, ContributionTracker.abi, signer);

      const tx = await contract.contribute({ value: ethers.utils.parseEther('0.1') });
      await tx.wait();

      const contrib = await contract.getContribution(address);
      setContribution(contrib.toString());

      const tokens = await contract.getTokenBalance(address);
      setTokenBalance(tokens.toString());
    } catch (err) {
      setError(err.message);
      console.error('Error contributing:', err);
    }
  }

  return (
    <div>
      <h1>Contribution Tracker DApp</h1>
      {error && <p style={{ color: 'red' }}>Error: {error}</p>}
      <p>Your Contribution: {contribution} wei</p>
      <p>Your Token Balance: {tokenBalance}</p>
      <button onClick={contribute}>Contribute 0.1 Ether</button>
    </div>
  );
}