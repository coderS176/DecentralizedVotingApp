#include <iostream>
#include <string>
#include <unordered_map>
#include <vector>
#include <ctime>

class FoodSupplyChain {
public:
    // Enum to represent roles
    enum Role { Producer, Distributor, Retailer, Consumer };

    // Struct to represent a food item
    struct FoodItem {
        int id;
        std::string name;
        std::string origin;
        std::time_t timestamp;
        std::string currentOwner;
        Role currentRole;
        bool isAuthentic;
    };

private:
    // Container to store food items
    std::unordered_map<int, FoodItem> foodItems;
    int foodItemCount = 0;

public:
    // Add a new food item (only for producers)
    void addFoodItem(const std::string& name, const std::string& origin, const std::string& owner) {
        foodItemCount++;
        FoodItem item = { foodItemCount, name, origin, std::time(nullptr), owner, Role::Producer, true };
        foodItems[foodItemCount] = item;

        std::cout << "Food item added: ID=" << foodItemCount << ", Name=" << name << ", Origin=" << origin 
                  << ", Owner=" << owner << std::endl;
    }

    // Transfer ownership of a food item
    void transferOwnership(int id, const std::string& newOwner, Role newRole) {
        if (foodItems.find(id) == foodItems.end()) {
            std::cout << "Food item does not exist.\n";
            return;
        }

        FoodItem& item = foodItems[id];

        if (newRole <= item.currentRole) {
            std::cout << "Invalid role transition.\n";
            return;
        }

        item.currentOwner = newOwner;
        item.currentRole = newRole;
        item.timestamp = std::time(nullptr);

        std::cout << "Ownership transferred: ID=" << id << ", New Owner=" << newOwner 
                  << ", New Role=" << getRoleName(newRole) << std::endl;
    }

    // Retrieve food item details
    void getFoodItem(int id) const {
        if (foodItems.find(id) == foodItems.end()) {
            std::cout << "Food item does not exist.\n";
            return;
        }

        const FoodItem& item = foodItems.at(id);
        std::cout << "Food Item Details:\n"
                  << "ID: " << item.id << "\n"
                  << "Name: " << item.name << "\n"
                  << "Origin: " << item.origin << "\n"
                  << "Timestamp: " << std::ctime(&item.timestamp)
                  << "Current Owner: " << item.currentOwner << "\n"
                  << "Current Role: " << getRoleName(item.currentRole) << "\n"
                  << "Authentic: " << (item.isAuthentic ? "Yes" : "No") << "\n";
    }

private:
    // Helper function to get role name as a string
    std::string getRoleName(Role role) const {
        switch (role) {
            case Producer: return "Producer";
            case Distributor: return "Distributor";
            case Retailer: return "Retailer";
            case Consumer: return "Consumer";
            default: return "Unknown";
        }
    }
};

int main() {
    FoodSupplyChain supplyChain;

    // Add new food items
    supplyChain.addFoodItem("Apple", "Farm A", "Farmer John");
    supplyChain.addFoodItem("Banana", "Farm B", "Farmer Emily");

    // Transfer ownership
    supplyChain.transferOwnership(1, "Distributor Mike", FoodSupplyChain::Distributor);
    supplyChain.transferOwnership(2, "Retailer Sarah", FoodSupplyChain::Retailer);

    // Retrieve details
    supplyChain.getFoodItem(1);
    supplyChain.getFoodItem(2);

    return 0;
}
