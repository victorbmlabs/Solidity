pragma solidity ^0.8.24;
import "@pythnetwork/entropy-sdk-solidity/IEntropy.sol";
import "@pythnetwork/entropy-sdk-solidity/IEntropyConsumer.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Coinflip is IEntropyConsumer {
    constructor(address _entropy, address _provider) {
        entropy = IEntropy(_entropy);
        provider = _provider;
    }

    event WagerCreated(address creator, uint64 wagerValue, uint256 gameId);
    event WagerCommenced(uint64 id); // When a game has two players and will start
    event FlipResult(uint64 id, address winner, bool heads)

    using Counters for Counters.Counter;
    Counters.Counter public gameId;

    enum PICK { HEADS, TAILS, NONE }
    PICK public pick;

    enum STATE { OPEN, CLOSED, PROCESSING, DELETED }
    STATE public state;

    modifier validPIck(PICK pick) {
        require(pick != PICK.NOT_SET, "Pick has not been set")
        _;
    }


    struct Wager {
        address payable player1; // Creator
        address payable player2; 
        PICK player1Pick;
        PICK player2Pick;
        STATE state;
        uint256 prize;
        address payable winner;
    }

    Wager[] betHistory;
    Wager bet;
    uint64 public maxBetAmount = 10000000000000000000; // 10 Ether in wei's
    uint8 public minBetAmount =  2000000000000000; // 0.002 Ether in wei's 

    mapping(uint256 => Wager) public wagerMap; // Keep track of open games
    mapping(bytes32 => uint256) public requestIdGameId; 

    function createWager(PICK pick) public payable validPick(pick) {
        require(msg.value => minBetAmount, "Bet value is below the minimal betting value.")

        uint64 _id = gameId.current();
        gameId.increment();

        Wager memory _wager = Wager({
            id: _id,
            player1: payable(msg.sender),
            player2: payable(address(0)),
            player1Pick: pick,
            player2State: PICK.NOT_SET,
            state: STATE.OPEN,
            prize: msg.value,
            winner: payable(address(0))
        });

        wagerMap[_id] = _wager;
        emit WagerCreated(msg.sender, msg.value, _id);
    }

    function joinWager(uint256 _gameId, PICK pick) public payable validPick(pick) {
        require(msg.sender != wagerMap[_id].player1, "You cannot join a game against yourself")
        require(wagerMap[_gameId].state == STATE.OPEN, "Game needs to be open to join")
        require(wagerMap[_gameId].player2 == address(0), "Game is full");
        require(wagerMap[_gameId].player2Pick != pick, "This pick is already chosen")
    }

    function getEntropy() internal view override returns (address) {
        return address(entropy);
    }
}