// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract FruitMarketplace {
    struct Fruit {
        string name;
        uint price;
        address payable seller;
        bool available;
        address buyer;
    }

    struct Rating {
        uint rating;
        uint totalRating;
        uint numberOfRatings;
    }

    Fruit[] public fruits;

    mapping(address => uint[]) public sellerFruits;
    mapping(address => Rating) public sellerRatings;
    mapping(address => mapping(address => bool)) public hasRated;
    mapping(address => mapping(address => bool)) public hasBoughtFrom;

    event FruitAdded(
        uint indexed index,
        string name,
        uint price,
        address indexed seller
    );
    event FruitBought(uint indexed index, address indexed buyer, uint price);
    event SellerRated(
        address indexed seller,
        uint rating,
        address indexed rater
    );
    event FruitUpdated(uint indexed index, string name, uint price);

    // Ajouter un fruit
    function addFruit(string memory _name, uint _price) public {
        require(_price > 0, "Price must be greater than 0");
        fruits.push(
            Fruit(_name, _price, payable(msg.sender), true, address(0))
        );
        uint index = fruits.length - 1;
        sellerFruits[msg.sender].push(index);

        emit FruitAdded(index, _name, _price, msg.sender);
    }

    // Acheter un fruit
    function buyFruit(uint _index) public payable {
        require(_index < fruits.length, "Invalid fruit index");
        Fruit storage fruit = fruits[_index];
        require(fruit.available, "Fruit already sold");
        require(msg.value >= fruit.price, "Not enough funds");
        require(msg.sender != fruit.seller, "Seller cannot buy own fruit");

        fruit.available = false;
        fruit.buyer = msg.sender;
        fruit.seller.transfer(msg.value);
        hasBoughtFrom[msg.sender][fruit.seller] = true;

        emit FruitBought(_index, msg.sender, fruit.price);
    }

    // Noter un vendeur
    function rateSeller(address _seller, uint _rating) public {
        require(_rating <= 5, "Rating must be out of 5");
        require(
            !hasRated[msg.sender][_seller],
            "You already rated this seller"
        );
        require(
            hasBoughtFrom[msg.sender][_seller],
            "You must have bought from this seller"
        );

        sellerRatings[_seller].totalRating += _rating;
        sellerRatings[_seller].numberOfRatings += 1;
        hasRated[msg.sender][_seller] = true;

        emit SellerRated(_seller, _rating, msg.sender);
    }

    // Mettre à jour un fruit
    function updateFruit(uint _index, string memory _name, uint _price) public {
        require(_index < fruits.length, "Invalid fruit index");
        require(_price > 0, "Price must be greater than 0");

        Fruit storage fruit = fruits[_index];
        require(msg.sender == fruit.seller, "Only seller can update");
        require(fruit.available, "Fruit already sold");

        fruit.name = _name;
        fruit.price = _price;

        emit FruitUpdated(_index, _name, _price);
    }

    // Moyenne de note d’un vendeur
    function getSellerAverageRating(
        address _seller
    ) public view returns (uint) {
        Rating memory r = sellerRatings[_seller];
        if (r.numberOfRatings == 0) return 0;
        return r.totalRating / r.numberOfRatings;
    }

    // Nouvelle fonction : Nombre total de fruits
    function getFruitCount() public view returns (uint) {
        return fruits.length;
    }

    // Nouvelle fonction : Détails d’un fruit
    function getFruit(
        uint _index
    )
        public
        view
        returns (
            string memory name,
            uint price,
            address seller,
            bool available,
            address buyer
        )
    {
        require(_index < fruits.length, "Invalid fruit index");
        Fruit memory fruit = fruits[_index];
        return (
            fruit.name,
            fruit.price,
            fruit.seller,
            fruit.available,
            fruit.buyer
        );
    }
}
