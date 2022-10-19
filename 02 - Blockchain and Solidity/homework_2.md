
1. Using a blockchain explorer, have a look at the following transactions, what do they do ?


	1. 0x0ec3f2488a93839524add10ea229e773f6bc891b4eb4794c3337d4495263790b
	
		***I initially thought funds were being sent to some sort of DAO token distribution contract. But if you dig into the comments on the receiving address it says "This address was used in theDAO heist." So, perhaps it's a malicious contract?***
	
	2. 0x4fc1580e7f66c58b7c26881cce0aab9c3509afe6e507527f30566fbf8039bcd0

		***Funds sent from Uniswap to a Uniswap v2 router***

	3. 0x552bc0322d78c5648c5efa21d2daa2d0f14901ad4b15531f1ab5bbe5674de34f

		***Funds sent on PolyNetwork. Both addresses appear to be flagged for involvement in an Aug 2021 exploit***

		https://twitter.com/PolyNetwork2/status/1425073987164381196

		***Why are there so many recent micro-transactions to both of these accounts???***

	4. 0x7a026bf79b36580bf7ef174711a3de823ff3c93c65304c3acc0323c77d62d0ed

		***The hackers from 3 have sent the DAI tokens to a Maker: Dai Stablecoin contract. Why? No idea, lol***

	5. 0x814e6a21c8eb34b62a05c1d0b14ee932873c62ef3c8575dc49bcf12004714eda

		***160 eth sent to 1 of the exploiter addresses. But this is at least 9 days after the exploit, so I'm not really sure whats going on***

2. What is the largest account balance you can find ?

	***The Beacon deposit contract***

	0x00000000219ab540356cbb839cbe05303d7705fa
	
	14,321,767.00771856 Ether 

3. What is special about these accounts :
	1. 0x1db3439a222c519ab44bb1144fc28167b4fa6ee6

		***This is Vitalik's account***

	2. 0x000000000000000000000000000000000000dEaD

		***It's a burn addy. Is that 12.5k eth really lost for all eternity?***


4. Using [remix](https://remix.ethereum.org)  add [this](https://gist.github.com/extropyCoder/77487267da199320fb9c852cfde70fb1) contract as a source file 
	1. Compile the contract

		***done***

	2. Deploy the contract to the Remix VM environment

		***done***

