pragma solidity ^0.8.24;
import "@pythnetwork/entropy-sdk-solidity/IEntropy.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

using Counters for Counters.Counter;
enum PICK { HEADS, TAILS, NONE }
enum STATE { OPEN, CLOSED, PROCESSING }

struct Wager {
    address payable player1; // Creator
    address payable player2; 
    PICK player1Pick;
    PICK player2Pick;
    STATE state;
    uint256 prize;
    address payable winner;
}

contract Coinflip is IEntropyConsumer {
    constructor(address _entropy, address _provider) {
        entropy = IEntropy(_entropy);
        provider = _provider;
    }

    event WagerCreated(address creator, uint64 wagerValue, uint256 gameId);
    event WagerCommenced(uint64 id); // When a game has two players and will start
    event FlipResult(uint64 id, address winner, bool heads)

    Counters.Counter public gameId;
    PICK public pick;
    STATE public state;

    modifier validPick(PICK pick) {
        require(pick != PICK.NOT_SET, "Pick has not been set")
        _;
    }

    Wager[] betHistory;
    Wager bet;
    uint64 public maxBetAmount = 10000000000000000000; // 10 Ether in wei's
    uint8 public minBetAmount =  2000000000000000; // 0.002 Ether in wei's 

    mapping(uint64 => Wager) public wagerMap; // Keep track of open games
    mapping(bytes32 => uint256) public requestIdGameId; 

    function createWager(PICK pick) public payable validPick(pick) {
        require(msg.value => minBetAmount, "Bet value is below the minimal betting value.")

        uint64 id = gameId.current();
        gameId.increment();

        Wager memory wager = Wager({ // Make a copy of the wager object
            id: id,
            player1: payable(msg.sender),
            player2: payable(address(0)),
            player1Pick: pick,
            player2State: PICK.NOT_SET,
            state: STATE.OPEN,
            prize: msg.value,
            winner: payable(address(0))
        });

        wagerMap[id] = wager;
        emit WagerCreated(msg.sender, msg.value, id);
    }

    function closeWager(uint64 gameId) public onlyOwner {
        require(wagerMap[gameId] != 0, "This wager does not exist")
        require(wagerMap[gameId].state == STATE.OPEN, "Game is not open")
        Wager storage wager = wagerMap[gameId];
        wager.player1.transfer(wager.prize);

        delete wagerMap[gameId]; // Don't store games that haven't been played
    }

    function joinWager(uint64 gameId, PICK pick) public payable validPick(pick) {
        Wager storage wager = wagerMap[gameId]; // Get the reference to struct for persistant modification

        require(msg.sender != wager.player1, "You cannot join a game against yourself")
        require(wager.state == STATE.OPEN, "Game needs to be open to join")
        require(wager.player2 == address(0), "Game is full");
        require(wager.player2Pick != pick, "This pick is already chosen")
        // add require check to see if join bet is within 1-2% of actual wager bet

        wager.player2Pick = pick;
        wager.prize += msg.value;
        wager.state = STATE.PROCESSING;
        wager.player2 = payable(msg.sender);

        emit WagerCommenced(wager.id)

        flip(wager);
    }

    function flip(Wager wager) internal {
        /* Handles the winner selection via Pyth entropy & pays out to the winner. */
    }

    function getEntropy() internal view override returns (address) {
        return address(entropy);
    }

    function isBetMatched() {

    }
}