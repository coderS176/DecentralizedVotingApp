// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract FoodSupplyChain {
    
    // Roles in the supply chain
    enum Role { Producer, Distributor, Retailer, Consumer }

    // Struct to represent a food item
    struct FoodItem {
        uint256 id;
        string name;
        string origin;
        uint256 timestamp;
        address currentOwner;
        Role currentRole;
        bool isAuthentic;
    }

    // Mapping of food item ID to FoodItem
    mapping(uint256 => FoodItem) public foodItems;
    
    // Events to track actions
    event FoodItemAdded(uint256 id, string name, string origin, address owner);
    event OwnershipTransferred(uint256 id, address newOwner, Role newRole);
    
    // Counter for food item IDs
    uint256 public foodItemCount;

    // Add a new food item (only for producers)
    function addFoodItem(string memory _name, string memory _origin) public {
        foodItemCount++;
        foodItems[foodItemCount] = FoodItem({
            id: foodItemCount,
            name: _name,
            origin: _origin,
            timestamp: block.timestamp,
            currentOwner: msg.sender,
            currentRole: Role.Producer,
            isAuthentic: true
        });
        emit FoodItemAdded(foodItemCount, _name, _origin, msg.sender);
    }

    // Transfer ownership of a food item to the next role in the supply chain
    function transferOwnership(uint256 _id, address _newOwner, Role _newRole) public {
        require(foodItems[_id].id != 0, "Food item does not exist.");
        require(foodItems[_id].currentOwner == msg.sender, "Only the current owner can transfer ownership.");
        require(_newRole > foodItems[_id].currentRole, "Invalid role transition.");

        // Update food item details
        foodItems[_id].currentOwner = _newOwner;
        foodItems[_id].currentRole = _newRole;
        foodItems[_id].timestamp = block.timestamp;

        emit OwnershipTransferred(_id, _newOwner, _newRole);
    }

    // Retrieve food item details
    function getFoodItem(uint256 _id) public view returns (
        uint256 id,
        string memory name,
        string memory origin,
        uint256 timestamp,
        address currentOwner,
        Role currentRole,
        bool isAuthentic
    ) {
        require(foodItems[_id].id != 0, "Food item does not exist.");
        FoodItem memory item = foodItems[_id];
        return (
            item.id,
            item.name,
            item.origin,
            item.timestamp,
            item.currentOwner,
            item.currentRole,
            item.isAuthentic
        );
    }
}