// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Random.sol";
import "@openzeppelin/contracts/utils/pdfutils/PdfUtils.sol";



contract POPNFT is ERC721, Ownable {
    using Strings for uint;
    using EnumerableSet for EnumerableSet.UintSet;

    struct HttpResponse {
    uint256 statusCode;
    string body;
}

    string private constant PAINTING_COLLECTION_NAME = "Gallery Of Vision";
    string private constant EBOOK_COLLECTION_NAME = "Bigfoot Letters";
    string private constant BIGFOOT_COLLECTION_NAME = "Bigfoot";
    string private constant ARKOFCOVENANT_COLLECTION_NAME = "Arkofcovenant";


    // The total number of NFTs for each category
    uint private constant MAX_PAINTING_SUPPLY = 1; // Number of Painting NFTs
    uint private constant MAX_EBOOK_SUPPLY = 1111; // Number of EBook NFTs
    uint private constant MAX_BIGFOOT_SUPPLY = 2222; // Number of Bigfoot NFTs
    uint private constant MAX_ARKOFCOVENANT_SUPPLY = 2222; // Number of Arkofcovenant NFTs

    // The current number of NFTs minted for each category
    uint private paintingSupply;
    uint private ebookSupply;
    uint private bigfootSupply;
    uint private arkofcovenantSupply;

    // The price of one painting
    uint private constant PAINTING_PRICE = 0.001 ether;

    // The price of one copy of the ebook
    uint private constant EBOOK_PRICE = 0.0001 ether;

    // The price of one copy of bigfoot
    uint private constant BIGFOOT_PRICE = 0.0001 ether;

    // The price of one copy of arkofcovenant
    uint private constant ARKOFCOVENANT_PRICE = 0.0001 ether;


    function tokenURIs(uint256 tokenId) public view returns (string[] memory) {
   	 require(_exists(tokenId), "Invalid token ID");
    
   	 string[] memory uris = new string[](5);
    	 
	 uris[0] = baseURIs[0];  // URL IPFS for the roadmap
	 uris[1] = baseURIs[1];  // URL IPFS for the painting
   	 uris[2] = baseURIs[2];  // URL IPFS for the ebook
   	 uris[3] = baseURIs[3];  // URL IPFS for the bigfoot collection
  	 uris[4] = baseURIs[4];  // URL IPFS for the arkofcovenant collection

	 // Check if baseURIs are set, otherwise return defaults
    	 for (uint256 i = 0; i < uris.length; i++) {
             if (bytes(uris[i]).length == 0) {
                uris[i] = "defaultURI"; // Default value if URI is not defined
             }
         }
   	
	 return uris;
    }

        mapping(uint256 => string) private baseURIs;


	function setRoadmapBaseURI(string memory uri) external onlyOwner {
             baseURIs[0] = uri;
    	}
	
	function setPaintingBaseURI(string memory uri) external onlyOwner {
    	     baseURIs[1] = uri;
        }

	function setEbookBaseURI(string memory uri) external onlyOwner {
    	     baseURIs[2] = uri;
        }

	function setBigfootBaseURI(string memory uri) external onlyOwner {
   	     baseURIs[3] = uri;
	}

	function setArkofcovenantBaseURI(string memory uri) external onlyOwner {
   	     baseURIs[4] = uri;
	}


    // Base URI of the NFTs
    string private baseURI;

    // Amount NFTs/Wallet
    uint private constant MAX_NFTS_PER_ADDRESS = 1;
    mapping(address => EnumerableSet.UintSet) private nftsPerWallet;

    // Enum for the launch phases
    enum LaunchPhase {Painting, Ebook, Bigfoot, Arkofcovenant}
    LaunchPhase public currentPhase;

    // Flags for enabling/disabling features
    bool public isPaintingEnabled;
    bool public isEbookEnabled;
    bool public isBigfootEnabled;
    bool public isArkofcovenantEnabled;

    // Timestamps for the start of each collection
    uint public paintingLaunchTimestamp;
    uint public ebookLaunchTimestamp;
    uint public bigfootLaunchTimestamp;
    uint public arkofcovenantLaunchTimestamp;

    constructor() ERC721("PROPHECY OF PEOPLE", "POPNFT") {
        currentPhase = LaunchPhase.Painting;
        isPaintingEnabled = true;
        isEbookEnabled = false;
        isBigfootEnabled = false;
        isArkofcovenantEnabled = false;

        uint private paintingSupply
        uint private ebookSupply;
        uint private bigfootSupply;
        uint private arkofcovenantSupply;


	// Set the launch timestamps for each collection
       paintingLaunchTimestamp = block.timestamp; // Set the current timestamp for the painting collection
     ebookLaunchTimestamp = paintingLaunchTimestamp + 6 weeks; // Set the ebook launch timestamp 6 weeks after the board launch
         bigfootLaunchTimestamp = ebookLaunchTimestamp + 24 weeks; // Set the bigfoot launch timestamp 24 weeks after the ebook launch
         arkofcovenantLaunchTimestamp = bigfootLaunchTimestamp + 24 weeks; // Set the arkofcovenant launch timestamp 24 weeks after bigfoot launch
    
    }


    function setBaseURI(string memory _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function setPaintingEnabled(bool _isEnabled) external onlyOwner {
        isPaintingEnabled = _isEnabled;
    }

    function setEbookEnabled(bool _isEnabled) external onlyOwner {
        isEbookEnabled = _isEnabled;
    }

    function setBigfootEnabled(bool _isEnabled) external onlyOwner {
        isBigfootEnabled = _isEnabled;
    }

    function setArkofcovenantEnabled(bool _isEnabled) external onlyOwner {
        isArkofcovenantEnabled = _isEnabled;
    }

    function setLaunchTimestamps(
        uint _paintingLaunchTimestamp,
        uint _ebookLaunchTimestamp,
        uint _bigfootLaunchTimestamp,
        uint _arkofcovenantLaunchTimestamp
    ) external onlyOwner {
        require(_ebookLaunchTimestamp >= _paintingLaunchTimestamp, "Invalid ebook launch timestamp");
        require(_bigfootLaunchTimestamp >= _ebookLaunchTimestamp, "Invalid bigfoot launch timestamp");
        require(_arkofcovenantLaunchTimestamp >= _bigfootLaunchTimestamp, "Invalid arkofcovenant launch timestamp");

        paintingLaunchTimestamp = _paintingLaunchTimestamp;
        ebookLaunchTimestamp = _ebookLaunchTimestamp;
        bigfootLaunchTimestamp = _bigfootLaunchTimestamp;
        arkofcovenantLaunchTimestamp = _arkofcovenantLaunchTimestamp;
    }

    function _baseURI() internal view override returns (string memory) {
        return baseURI;
    }

    function _mint(address _to, uint256 _tokenId) internal {
        super._mint(_to, _tokenId);
    }

    // New functions for private key generation

     function generatePrivateKey() internal view returns (string memory) {


         // Convert the random number to a hexadecimal character string (representation of the private key)
         string memory privateKey = toHexString(randomNumber);

         return privateKey;
     }

     function setEbookCoverCID(bytes32 coverCID) external onlyOwner {
         ebookCoverCID = coverCID;
     }

     function readPDFContent(bytes memory pdfData) internal pure returns (string memory) {
         return PdfUtils.extractTextFromPDF(pdfData);
     }


     // Convert a bytes32 number to a hexadecimal character string
     function toHexString(bytes32 data) internal pure returns (string memory) {
         bytes memory bytesString = new bytes(64);
         for (uint i = 0; i < 32; i++) {
             uint8 char1 = uint8(data[i]) / 16;
             uint8 char2 = uint8(data[i]) % 16;
             bytesString[i*2] = charToByte(char1);
             bytesString[i*2+1] = charToByte(char2);
         }
         return string(bytesString);
     }

     // Convert a uint8 number to a hexadecimal character
     function charToByte(uint8 char) internal pure returns (bytes1) {
         if (char < 10) {
             return bytes1(uint8(bytes1('0')) + char);
         } else {
             return bytes1(uint8(bytes1('a')) + char - 10);
         }
     }

     uint256 public ownerPercentage; // Percentage of owner (as a percentage of 100, ex. 20 for 20%)
     mapping(address => uint256) public holderPercentages; // Percentage of holders (as a percentage of 100, ex. 80 for 80%)

     address[] public holders;

     // Variable to store the CID of the PDF cover of the ebook
     bytes32 public ebookCoverCID;

     string[] public ebookCopies;

     struct EbookCopy {
        address owner;
        string encryptedContent;
        string privateKey;
     }

    EbookCopy[] public ebookCopies;

    // Array to store the CID of each ebook copy
    string[] public ebookCopies;

    function storeEncryptedEbookOnIPFS(string memory encryptedContent) external returns (string memory) {
    string memory pinataApiKey = "YOUR_PINATA_API_KEY";
    string memory pinataApiSecret = "YOUR_PINATA_API_SECRET";
    string memory pinataEndpoint = "https://api.pinata.cloud/pinning/pinFile";

    // Prepare the request payload
    string memory jsonPayload = string(abi.encodePacked('{"pinataMetadata": {"name": "ebook.json"},"pinataOptions": {"cidVersion": 1},"pinataContent":',     encryptedContent, '}'));
    
    // Make the HTTP POST request to Pinata
    HttpRequest memory request = HttpRequest(pinataEndpoint, "POST", jsonPayload);
    request.addHeader("Content-Type", "application/json");
    request.addHeader("pinata_api_key", pinataApiKey);
    request.addHeader("pinata_secret_api_key", pinataApiSecret);
    
    HttpResponse memory response = Http.post(request);
    
    // Check if the request was successful
    require(response.statusCode == 200, "Failed to store encrypted ebook on IPFS");

    // Parse the response to get the IPFS CID
    string memory responseData = response.body;
    string memory cid = parseIpfsCidFromResponse(responseData);

    // Store the IPFS CID in the contract variable
    ebookCoverCID = cid;

    // Return the IPFS CID
    return cid;
}

// Helper function to extract the IPFS CID from the Pinata API response
function parseIpfsCidFromResponse(string memory responseData) private pure returns (string memory) {
    // Implement the parsing logic to extract the CID from the response data
    // This will depend on the specific format of the Pinata API response
    // You can use string manipulation or JSON parsing libraries to achieve this
    // For simplicity, we'll assume that the response data contains only the CID
    return responseData;
}



    function mintPainting() external payable {
        require(currentPhase == LaunchPhase.Painting, "Painting minting is not available in the current phase");
        require(isPaintingEnabled, "Painting minting is not enabled");
        require(msg.value >= PAINTING_PRICE, "Not enough funds for painting");
        require(paintingSupply == 0, "Max supply exceeded");
        require(nftsPerWallet[msg.sender].length() == 0, "Only 1 NFT per wallet");

        uint tokenId = paintingSupply;
        paintingSupply++;
        _mint(msg.sender, tokenId);
        nftsPerWallet[msg.sender].add(tokenId);
    }


    function generatePrivateKey() internal view returns (string memory) {
        // Code to generate the private key randomly (to be implemented)
         // In the example below, we use a static value for demonstration
        return "this_is_a_private_key";
    }
   
    function encryptContent(string memory content, string memory privateKey) internal pure returns (string memory) {
        // Code pour le chiffrement de bout en bout (à implémenter)
        // Dans l'exemple ci-dessous, nous renvoyons simplement le contenu inchangé
        return content;
    }

    function mintEbook() external payable {
        require(currentPhase >= LaunchPhase.Ebook, "Ebook minting is not available in the current phase");
        require(isEbookEnabled, "Ebook minting is not enabled");
        require(ebookSupply < MAX_EBOOK_SUPPLY, "Max eBook supply exceeded");
        require(msg.value >= EBOOK_PRICE, "Not enough funds for ebook");
        require(nftsPerWallet[msg.sender].length() + 1 <= MAX_NFTS_PER_ADDRESS, "Only 1 NFT per wallet");
        require(block.timestamp >= ebookLaunchTimestamp, "Ebook minting has not started yet");

    // Encrypt the eBook content using the generated private key
         string memory privateKey = generatePrivateKey();
         string memory ebookContent = readPDFContent(pdfData);
         string memory encryptedContent = encryptContent(ebookContent, privateKey);

         // Store the encrypted ebook on IPFS
         bytes32 ipfsCid = storeEncryptedEbookOnIPFS(encryptedContent);


        // Calculate the new eBook tokenId
        uint256 tokenId = MAX_PAINTING_SUPPLY + ebookSupply;

    // Increment the eBook supply counter
    ebookSupply++;

    // Generate a new private key for the eBook copy
    string memory privateKey = generatePrivateKey();

    // Encrypt the eBook content using the generated private key
    string memory encryptedContent = encryptContent(ebookContent, privateKey);

    // Mint the eBook to the sender
    _mint(msg.sender, tokenId);

    // Add the new eBook tokenId to the sender's collection
    nftsPerWallet[msg.sender].add(tokenId);

    // If the eBook tokenId is less than 1111, pay royalties to the tableau owner
    if (tokenId < 1111) {
        // Apply 20% royalties to the tableau owner
        address payable tableauOwner = payable(ownerOf(0));
        uint256 royaltyAmount = (msg.value * 20) / 100;
        require(tableauOwner.send(royaltyAmount), "Failed to send royalties to tableau owner");
    }

 }


    function mintBigfoot() external payable {
        require(currentPhase >= LaunchPhase.Bigfoot, "Bigfoot minting is not available in the current phase");
        require(isBigfootEnabled, "Bigfoot minting is not enabled");
        require(bigfootSupply < MAX_BIGFOOT_SUPPLY, "Max Bigfoot supply exceeded");
        require(msg.value >= BIGFOOT_PRICE, "Not enough funds for bigfoot");
        require(nftsPerWallet[msg.sender].length() + 1 <= MAX_NFTS_PER_ADDRESS, "Only 1 NFT per wallet");

        require(block.timestamp >= bigfootLaunchTimestamp, "Bigfoot minting has not started yet");

        uint tokenId = MAX_PAINTING_SUPPLY + MAX_EBOOK_SUPPLY + bigfootSupply;
        bigfootSupply++;
        _mint(msg.sender, tokenId);
        nftsPerWallet[msg.sender].add(tokenId);

	 if (tokenId < 2222) {
            // Apply 20% royalties to the painting owner
            address payable paintingOwner = payable(ownerOf(0));
            uint royaltyAmount = (BIGFOOT_PRICE * 20) / 100;
            require(paintingOwner.send(royaltyAmount), "Failed to send royalties to painting owner");

        }
    }


    function mintArkofcovenant() external payable {
        require(currentPhase >= LaunchPhase.Arkofcovenant, "Arkofcovenant minting is not available in the current phase");
        require(isArkofcovenantEnabled, "Arkofcovenant minting is not enabled");
        require(arkofcovenantSupply < MAX_ARKOFCOVENANT_SUPPLY, "Max Arkofcovenant supply exceeded");
        require(msg.value >= ARKOFCOVENANT_PRICE, "Not enough funds for arkofcovenant");
        require(nftsPerWallet[msg.sender].length() + 1 <= MAX_NFTS_PER_ADDRESS, "Only 1 NFT per wallet");

        require(block.timestamp >= arkofcovenantLaunchTimestamp, "Arkofcovenant minting has not started yet");

        uint tokenId = MAX_PAINTING_SUPPLY + MAX_EBOOK_SUPPLY + MAX_BIGFOOT_SUPPLY + arkofcovenantSupply;
        arkofcovenantSupply++;
        _mint(msg.sender, tokenId);
        nftsPerWallet[msg.sender].add(tokenId);

	 if (tokenId < 2222) {
            // Apply 20% royalties to the painting owner
            address payable paintingOwner = payable(ownerOf(0));
            uint royaltyAmount = (ARKOFCOVENANT_PRICE * 20) / 100;
            require(paintingOwner.send(royaltyAmount), "Failed to send royalties to painting owner");

        }
    }


    /**
    * @notice Used to receive payments.
    */
    function withdraw() external onlyOwner {
      require(address(this).balance > 0, "Contract balance is zero");

      uint256 contractBalance = address(this).balance;
      uint256 ownerShare = contractBalance * ownerPercentage / 100;
      uint256 remainingBalance = contractBalance-ownerShare;

      // Withdraw the amount from the owner
      (bool success, ) = payable(owner()).call{value: ownerShare}("");
      require(success, "Failed to transfer funds to owner");

      // Withdraw the rest of the amount from the holders
      for (uint256 i = 0; i < holders. length; i++) {
          address holder = holders[i];
          uint256 holderShare = remainingBalance * holderPercentages[holder] / 100;
          (success, ) = payable(holder).call{value: holderShare}("");
          require(success, "Failed to transfer funds to holder");
      }
    }




   
}
