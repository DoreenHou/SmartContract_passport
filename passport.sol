// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

contract ThailandVisa {
    enum VisaType {Travel, Business, Study}

    struct Applicant {
        string passengerName;
        uint256 birthYear;
        uint256 birthMonth;
        uint256 birthDay;
        string idNumber;
        string nationality;
        string passportNumber;
        VisaType visaType;
        bool approved;
        uint256 visaExpiration;
        uint256 visaFee;
    }

    mapping(address => Applicant) public applicants;

    address public admin;

    constructor() {
        admin = msg.sender;
    }

    function passengerApply(
        string memory _name,
        uint256 _birthYear,
        uint256 _birthMonth,
        uint256 _birthDay,
        string memory _idNumber,
        string memory _nationality,
        string memory _passportNumber,
        VisaType _visaType
    ) public payable {
        require(
            applicants[msg.sender].approved == false,
            "You have already been approved"
        );
        require(
            msg.value == 1 ether,
            "The visa fee must be 1 ether."
        );
        require(_birthYear <= 2024, "Invalid birth year");
        require(_birthMonth >= 1 && _birthMonth <= 12, "Invalid birth month");
        require(_birthDay >= 1 && _birthDay <= 31, "Invalid birth day");
        require(
            bytes(_idNumber).length == 10,
            "ID number must be 10 characters long"
        );
        require(
            uint8(bytes(_idNumber)[0]) >= 65 &&
                uint8(bytes(_idNumber)[0]) <= 90,
            "ID number must start with an uppercase letter"
        );
        for (uint256 i = 1; i < bytes(_idNumber).length; i++) {
            require(
                uint8(bytes(_idNumber)[i]) >= 48 &&
                    uint8(bytes(_idNumber)[i]) <= 57,
                "Last 9 characters of ID number must be digits"
            );
        }
        require(
            bytes(_passportNumber).length == 9,
            "Passport number must be 9 characters long"
        );
        applicants[msg.sender] = Applicant(
            _name,
            _birthYear,
            _birthMonth,
            _birthDay,
            _idNumber,
            _nationality,
            _passportNumber,
            _visaType,
            false,
            0,
            msg.value
        );
    }

    function approve(address _applicantAddress) public {
        require(
            msg.sender == admin,
            "Only admin can approve applicants"
        );
        require(
            applicants[_applicantAddress].approved == false,
            "Applicant has already been approved"
        );
        applicants[_applicantAddress].approved = true;
        applicants[_applicantAddress].visaExpiration =
            block.timestamp +
            90 days;
    }

    function revoke(address _applicantAddress) public {
        require(
            msg.sender == admin,
            "Only admin can revoke applicants"
        );
        require(
            applicants[_applicantAddress].approved == true,
            "Applicant has not been approved yet"
        );
        payable(msg.sender).transfer(applicants[_applicantAddress].visaFee);
        applicants[_applicantAddress].approved = false;
        applicants[_applicantAddress].visaExpiration = 0;
        applicants[_applicantAddress].visaFee = 0;
    }

    function Info() public view returns (string memory) {
        string memory data = string(
            abi.encodePacked(
                "Passenger Name: ",
                applicants[msg.sender].passengerName,
                " | ",
                "Birthdate: ",
                uint2str(applicants[msg.sender].birthYear),
                "-",
                uint2str(applicants[msg.sender].birthMonth),
                "-",
                uint2str(applicants[msg.sender].birthDay),
                " | ",
                "ID Number: ",
                applicants[msg.sender].idNumber,
                " | ",
                "Nationality: ",
                applicants[msg.sender].nationality,
                " | ",
                "Passport Number: ",
                applicants[msg.sender].passportNumber,
                " | ",
                "Visa Type: ",
                visaTypeToString(applicants[msg.sender].visaType),
                " | ",
                "Approved: ",
                applicants[msg.sender].approved ? "Yes" : "No",
                " | ",
                "Visa Expiration: ",
                uint2str(applicants[msg.sender].visaExpiration),
                " | ",
                "Visa Fee: ",
                uint2str(applicants[msg.sender].visaFee),
                " Ether"
            )
        );
        return data;
    }

    function uint2str(uint256 _number) internal pure returns (string memory) {
        if (_number == 0) {
            return "0";
        }

        uint256 temp = _number;
        uint256 digits;

        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;

        while (_number != 0) {
            buffer[index--] = bytes1(uint8(48 + (_number % 10)));
            _number /= 10;
        }

        return string(buffer);
    }

    function visaTypeToString(VisaType _visaType)
        internal
        pure
        returns (string memory)
    {
        if (_visaType == VisaType.Travel) {
            return "Travel";
        } else if (_visaType == VisaType.Business) {
            return "Business";
        } else if (_visaType == VisaType.Study) {
            return "Study";
        } else {
            revert("Invalid visa type");
        }
    }
}
