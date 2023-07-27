//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.7.0;
import "@openzeppelin/contracts/utils/Strings.sol";

contract simple {
    struct Manufacturer {
        bytes32 id ;
        bool isauth ;
        string name ;
        bytes32 [] products ;
    }

    struct Product {
        bytes32 id ;
        bytes32 owner ;
        bool isauth ;
        string name ;
        bytes32 [] history ;
    }

    struct User {
        bytes32 id ;
        string name ;
        bool isauth ;
    }

    uint public manufacturer_count;
    uint public product_count;
    uint public user_count;

    mapping (bytes32 => Product) public products;
    mapping (bytes32 => Manufacturer) public manufacturers;
    mapping (bytes32 => User) public users;


    event getId(bytes32);
    event error(string);

    function newManufacturer( string memory name ) external{
        manufacturer_count++;
        bytes32 uid = stringToBytes32 (string(abi.encodePacked ( "manufacturer_" , Strings.toString (manufacturer_count))));
        bytes32[] memory pro = new bytes32[](0);
        Manufacturer memory newm = Manufacturer({id:uid,isauth:true,name:name,products:pro});
        manufacturers[uid] = newm;
        emit getId(uid);
    }

    function newUser( string memory name ) external {
        user_count++;
        bytes32 uid = stringToBytes32( string(abi.encodePacked ( "user_" , Strings.toString (user_count))));
        User memory user = User({id:uid,name:name,isauth:true});
        users[uid] = user;
        emit getId(uid);
    }


    function changeOwner( bytes32 pid, bytes32 newid ) external {
        if( users[newid].isauth == false && manufacturers[newid].isauth == false){
            emit error("Not authorised");
        }
        else if( products[pid].isauth == false){
            emit error(" product not authorised ");
        }
        else {
            products[pid].history.push( products[pid].owner );
            products[pid].owner = newid;
        }
    }

    function newProduct( bytes32 mid, string memory name) external {
        if(manufacturers[mid].isauth == false){
            emit error("Only manufacturer can add product");
        }
        else{
            product_count++;
            bytes32 uid = stringToBytes32( string(abi.encodePacked ( "product_" , Strings.toString( product_count))));
            Product memory product = Product({id:uid,name:name,isauth:true,owner:mid,history: new bytes32[](0)});
            products[uid] = product;
            this.changeOwner(uid,mid);
            emit getId(uid);
        }
    }

    function getProductHistory ( bytes32 pid ) public view returns (bytes32[] memory){
        return products[pid].history;
    }

    function getProductDetails( bytes32 pid ) public view returns (Product memory, string memory) {
        string memory name;
        if(users[ products[pid].owner ].isauth){
            name = users[ products[pid].owner ].name;
        }
        else{
            name = manufacturers[ products[pid].owner ].name;
        }

        return (products[pid],name);
    }

    function stringToBytes32(string memory source) public pure returns (bytes32 result) {
        bytes memory tempEmptyStringTest = bytes(source);
        if (tempEmptyStringTest.length == 0) {
            return 0x0;
        }

        assembly {
            result := mload(add(source, 32))
        }
    }
}

