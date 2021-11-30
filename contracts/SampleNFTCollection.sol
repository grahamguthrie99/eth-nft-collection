pragma solidity ^0.8.0;

// We need some util functions for strings.
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "hardhat/console.sol";
import {Base64} from "./libraries/Base64.sol";

contract SampleNFTCollection is ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    // This is our SVG code. All we need to change is the word that's displayed. Everything else stays the same.
    // So, we make a baseSvg variable here that all our NFTs can use.
    string baseSvg =
        "<svg xmlns='http://www.w3.org/2000/svg' preserveAspectRatio='xMinYMin meet' viewBox='0 0 350 350'><style>.base { fill: white; font-family: serif; font-size: 24px; }</style><rect width='100%' height='100%' fill='black' />";

    // I create three arrays, each with their own theme of random words.
    // Pick some random funny words, names of anime characters, foods you like, whatever!

    struct Waypoint {
        string destination;
        string latitude;
        string longitude;
    }
    Waypoint[] waypoints;

    constructor() ERC721("SquareNFT", "SQUARE") {
        console.log("This is my NFT contract. Woah!");
        Waypoint memory atlanta = Waypoint(
            "Atlanta, GA USA",
            "33.7490 N",
            "84.3880 W"
        );
        Waypoint memory boston = Waypoint(
            "Boston, MA USA",
            "42.3601 N",
            "71.0589 W"
        );
        Waypoint memory chicago = Waypoint(
            "Chicago, IL USA",
            "41.8781 N",
            "87.6298 W"
        );
        waypoints.push(atlanta);
        waypoints.push(boston);
        waypoints.push(chicago);
    }

    // I create a function to randomly pick a word from each array.
    function pickWaypoint(uint256 tokenId)
        public
        view
        returns (
            string memory destination,
            string memory latitude,
            string memory longitude
        )
    {
        // I seed the random generator. More on this in the lesson.
        uint256 rand = random(
            string(abi.encodePacked("WAYPOINT", Strings.toString(tokenId)))
        );
        // Squash the # between 0 and the length of the array to avoid going out of bounds.
        rand = rand % waypoints.length;
        return (
            waypoints[rand].destination,
            waypoints[rand].latitude,
            waypoints[rand].longitude
        );
    }

    function random(string memory input) internal pure returns (uint256) {
        return uint256(keccak256(abi.encodePacked(input)));
    }

    function makeLocationNFT() public {
        uint256 newItemId = _tokenIds.current();

        // We go and randomly grab one word from each of the three arrays.
        (
            string memory destination,
            string memory latitude,
            string memory longitude
        ) = pickWaypoint(newItemId);

        // I concatenate it all together, and then close the <text> and <svg> tags.
        string memory finalSvg = string(
            abi.encodePacked(
                baseSvg,
                "<text x='50%' y='40%' class='base' dominant-baseline='middle' text-anchor='middle'>",
                destination,
                "</text>",
                "<text x='50%' y='50%' class='base' dominant-baseline='middle' text-anchor='middle'>",
                latitude,
                "</text>",
                "<text x='50%' y='60%' class='base' dominant-baseline='middle' text-anchor='middle'>",
                longitude,
                "</text></svg>"
            )
        );
        string memory json = Base64.encode(
            bytes(
                string(
                    abi.encodePacked(
                        '{"name": "',
                        // We set the title of our NFT as the generated word.
                        destination,
                        '", "description": "A highly acclaimed location.", "image": "data:image/svg+xml;base64,',
                        // We add data:image/svg+xml;base64 and then append our base64 encode our svg.
                        Base64.encode(bytes(finalSvg)),
                        '"}'
                    )
                )
            )
        );

        // Just like before, we prepend data:application/json;base64, to our data.
        string memory finalTokenUri = string(
            abi.encodePacked("data:application/json;base64,", json)
        );

        console.log("\n--------------------");
        console.log(finalTokenUri);
        console.log("--------------------\n");

        _safeMint(msg.sender, newItemId);

        // Update your URI!!!
        _setTokenURI(newItemId, finalTokenUri);

        _tokenIds.increment();
        console.log(
            "An NFT w/ ID %s has been minted to %s",
            newItemId,
            msg.sender
        );
    }
}
