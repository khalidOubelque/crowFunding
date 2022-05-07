// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13;

// Importing OpenZeppelin's SafeMath Implementation
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol';

contract Project {
    using SafeMath for uint256;
    enum State {
        Fundraising,
        Expired,
        Successful
    }
    address payable public projectCreator;
    string public projectTitle;
    string projectDescription; // IPFS
    uint256 amountGoal;
    uint256 currentBalance;
    State state;
    uint deadLine; // To be converted to date
    mapping(address=>uint256) contributions;

    // Event raised when fund received
    event FundReceivedBy(address _contributor,
                        uint256 _value);
    
    // Event raised when goal is reached
    event GoalReached(string _desc, string _projectTitle);

    // Event project funded
    event ProjectFunded(string _projectTitle, string _desc);

    // Event when project creator retreive funds
    event FundRetreived(string _desc, string _projectTitle);


    // Modifier to check current state
    modifier inState(State _state) {
        require(state == _state);
        _;
    }

    // Modifier to check the creator
    modifier isCreator(address _address) {
        require(projectCreator == _address);
        _;
    }

    // Modifier to check if funding delay is not expired
    modifier isFundingDelayNotExpired(){
        require(block.timestamp <= deadLine);
        _;
    }
    
    constructor
    (
        address payable _projectCreator,
        string memory _projectTitle,
        string memory _projectDescription,
        uint256 _amountGoal,
        uint _deadLine
    ) {
        projectCreator = _projectCreator;
        projectTitle = _projectTitle;
        projectDescription = _projectDescription;
        amountGoal = _amountGoal;
        deadLine = _deadLine;
        currentBalance = 0;
    }

    function start(string memory _projectTitle, string memory _projectDescription, 
        uint256 _amountGoal, uint256 _deadLine) internal {
            projectCreator = payable(msg.sender);
            projectTitle = _projectTitle;
            projectDescription = _projectDescription;
            amountGoal = _amountGoal;
            deadLine = _deadLine;
            setState(State.Fundraising);
        } 


    function contribute() public payable inState(State.Fundraising) isFundingDelayNotExpired {
        require(msg.sender != projectCreator);
        contributions[msg.sender] = contributions[msg.sender].add(msg.value); 
        currentBalance = currentBalance + msg.value;
        emit FundReceivedBy(msg.sender, msg.value);
        checkGoalReached();
    }


    // to check if the user had already contribut
    function isContributed() internal returns (bool){
        return contributions[msg.sender]>0 ? true : false;
    }

    function checkGoalReached() internal {
        if(amountGoal >= currentBalance){
            emit GoalReached("The Goal is reached", projectTitle);
            setState(State.Successful);
            payOut();
        }
    }

    function payOut() public inState(State.Successful){
        projectCreator.transfer(currentBalance);
        emit ProjectFunded(projectTitle, "is Funded");
    }

    
    // Retreive fund, even if goal not achieved, but the delay should be expired
    function retreiveFunds() isCreator(msg.sender) inState(State.Fundraising) public {
        require(block.timestamp > deadLine);
        setState(State.Expired);
        projectCreator.transfer(currentBalance);
        emit FundRetreived("Fund retreived", projectTitle);
    }

    function setState(State _state) internal {
        state = _state;
    }

    /** @dev Function to get specific information about the project.
      *  Returns all the project's details
      */
    function getDetails() public view returns 
    (
        address payable _projectStarter,
        string memory _projectTitle,
        string memory _projectDesc,
        uint256 _deadline,
        State _currentState,
        uint256 _currentAmount,
        uint256 _goalAmount
    ) {
        _projectStarter = projectCreator;
        _projectTitle = projectTitle;
        _projectDesc = projectDescription;
        _deadline = deadLine;
        _currentState = state;
        _currentAmount = currentBalance;
        _goalAmount = amountGoal;
    }
}