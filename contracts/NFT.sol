pragma solidity ^0.8.0;

contract RES4Token {
    struct Asset {
        address owner;
        string address1;
        string address2;
        string city;
        string state;
        string country;
        uint256 value;
        address approvedBuyer;
    }

    Asset[] public assets;

    mapping(address => uint256[]) public ownerToAssets;
    mapping(address => mapping(uint256 => bool)) public ownerToAsset;

    event AssetAdded(address indexed owner, uint256 indexed assetId);
    event AssetValueChanged(uint256 indexed assetId, uint256 newValue);
    event AssetApprovedForSale(uint256 indexed assetId, address indexed approvedBuyer);
    event AssetPurchased(uint256 indexed assetId, address indexed newOwner, uint256 newValue);
    event AssetValueUpdated(uint256 indexed assetId, uint256 newValue);

    function addAsset(
        string memory _address1,
        string memory _address2,
        string memory _city,
        string memory _state,
        string memory _country,
        address _owner
    ) public returns (uint256 assetId) {
        assetId = assets.length;
        assets.push(
            Asset({
                owner: _owner,
                address1: _address1,
                address2: _address2,
                city: _city,
                state: _state,
                country: _country,
                value: 0,
                approvedBuyer: address(0)
            })
        );
        ownerToAssets[_owner].push(assetId);
        ownerToAsset[_owner][assetId] = true;
        emit AssetAdded(_owner, assetId);
    }

    function getAsset(uint256 _assetId)
        public
        view
        returns (
            address owner,
            string memory address1,
            string memory address2,
            string memory city,
            string memory state,
            string memory country,
            uint256 value,
            address approvedBuyer
        )
    {
        Asset storage asset = assets[_assetId];
        owner = asset.owner;
        address1 = asset.address1;
        address2 = asset.address2;
        city = asset.city;
        state = asset.state;
        country = asset.country;
        value = asset.value;
        approvedBuyer = asset.approvedBuyer;
    }

    function addValue(uint256 _assetId, uint256 _value) public {
        require(ownerToAsset[msg.sender][_assetId], "You do not own this asset");
        Asset storage asset = assets[_assetId];
        asset.value += _value;
        emit AssetValueChanged(_assetId, asset.value);
    }

    function approveSale(uint256 _assetId, address _approvedBuyer) public {
        require(ownerToAsset[msg.sender][_assetId], "You do not own this asset");
        Asset storage asset = assets[_assetId];
        asset.approvedBuyer = _approvedBuyer;
        emit AssetApprovedForSale(_assetId, _approvedBuyer);
    }

    function purchaseAsset(uint256 _assetId) public payable {
        Asset storage asset = assets[_assetId];
        require(msg.sender == asset.approvedBuyer, "You are not approved to buy this asset");
        require(msg.value == asset.value, "Incorrect value sent");
        address payable previousOwner = payable(asset.owner);
        asset.owner = msg.sender;
        asset.value = 0;
        asset.approvedBuyer = address(0);
        ownerToAsset[previousOwner][_assetId] = false;
        ownerToAsset[msg.sender][_assetId] = true;
        emit AssetPurchased(_assetId, msg.sender, msg.value);
    }
}
