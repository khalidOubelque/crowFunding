// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.13; 

import "./Project.sol";
// Importing OpenZeppelin's SafeMath Implementation
import 'https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol';

contract Crowfunding {
    using SafeMath for uint256;
    Project[] private projects;


    constructor() 
    {
        Project newProject = new Project(payable(msg.sender), "Default","Default",100,12);
        projects.push(newProject);

    }

    // Event that will be emitted whenever a new project is started
    event ProjectStarted(
        address contractAddress,
        address projectCreator,
        string projectTitle,
        string projectDesc,
        uint256 deadline,
        uint256 goalAmount,
        Project.State state
    );


    /** @dev Function to get all projects' contract addresses.
      * @return A list of all projects' contract addreses
      */
    function returnAllProjects() external view returns(Project[] memory){
        return projects;
    }


    function checkProjectExistence(address _address) internal returns(bool _isExist, Project _project){
         for(uint i=0; i<projects.length; i++){
           if(projects[i].projectCreator() == _address){
               _isExist = true;
               _project = projects[i];
               return (_isExist,_project);
           }
           revert('Not found');
       }   
    }

    function getProjectByAddressCreator(address _address) public view returns (Project) {
       for(uint i=0; i<projects.length; i++){
           if(projects[i].projectCreator() == _address){
               return projects[i];
           }
       }        
       revert("Project not found !!");
    }

    function startProject (string memory _projectTitle, string memory _projectDescription, 
        uint256 _amountGoal, uint256 _nbDays) public {
         uint _raiseUntil = block.timestamp.add(_nbDays.mul(1 days));
         Project newProject = new Project(payable(msg.sender), _projectTitle,_projectDescription,_amountGoal,_raiseUntil);
         projects.push(newProject);

        emit ProjectStarted(
            address(newProject),
            msg.sender,
            _projectTitle,
            _projectDescription,
            _raiseUntil,
            _amountGoal,
            Project.State.Fundraising
        );
    }

    // contribute to a certain project
    function contribute(address _addressProjectCreator) payable public {
        (bool isExist, Project project) = checkProjectExistence(_addressProjectCreator);
        if(isExist) {
            project.contribute();
        }
    }


    // Retreive fund, even if goal not achieved, but the delay should be expired
    function retreiveFunds() public {
        (bool isExist, Project project) = checkProjectExistence(msg.sender);
        if(isExist) {
            project.retreiveFunds();
        }

    }


}