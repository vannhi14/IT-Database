create database tutorial;
go
use tutorial;

-- Tạo bảng Người dùng
CREATE TABLE Us (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    UsName VARCHAR(255),
    Email VARCHAR(255) UNIQUE,
    PhoneNumber VARCHAR(255) UNIQUE,
    UsAddress VARCHAR(255),
    YearOfBirth INT,
    Sex VARCHAR(10)
);

-- Tạo bảng Gia sư
CREATE TABLE Tutor (
    UserID INT PRIMARY KEY,
    Certifications TEXT,
    Experience TEXT,
    Subjects TEXT, -- Cần thay đổi để quản lý đa trị
    AverageRating FLOAT,
    NumOfCourses INT,
    FOREIGN KEY (UserID) REFERENCES Us(ID),
);


-- Tạo bảng Học viên
CREATE TABLE Student (
    UserID INT PRIMARY KEY,
    EnrolledCourses TEXT, -- Cần thay đổi để quản lý đa trị
    FOREIGN KEY (UserID) REFERENCES Us(ID)
);

-- Tạo bảng Khóa học
CREATE TABLE Course (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    CourseName VARCHAR(255),
    CourseDescription TEXT,
    Capacity INT,
    MinimumStudents INT,
    TutorID INT,
	FOREIGN KEY (TutorID) REFERENCES Tutor(UserID),
);

-- Tạo bảng Đánh giá
CREATE TABLE Review (
    ID INT IDENTITY(1,1) PRIMARY KEY,
    CourseID INT,
    StudentID INT,
    Rating INT,
    Comment TEXT,
    FOREIGN KEY (CourseID) REFERENCES Course(ID),
    FOREIGN KEY (StudentID) REFERENCES Student(UserID)
);

-- Tạo bảng Tài khoản
CREATE TABLE Account (
    UserID INT UNIQUE,
    Username VARCHAR(255),
    AccPassword VARCHAR(255),
    AccRole VARCHAR(50),
    FOREIGN KEY (UserID) REFERENCES Us(ID)
);

-- Tạo bảng Đăng ký khóa học
CREATE TABLE CourseRegistration (
    StudentID INT,
    CourseID INT,
    CourseStatus VARCHAR(50),
    FOREIGN KEY (StudentID) REFERENCES Student(UserID),
    FOREIGN KEY (CourseID) REFERENCES Course(ID)
);
-- -- -- -- -- -- -- -- -- 
INSERT INTO Us (UsName, Email, PhoneNumber, UsAddress, YearOfBirth, Sex) VALUES
('Nguyen Van A', 'nguyenvana@example.com', '0901234567', '123 Hai Ba Trung, Ha Noi', 1985, 'Male'),
('Tran Thi B', 'tranthib@example.com', '0901234568', '456 Dien Bien Phu, Ha Noi', 1990, 'Female'),
('Le Van C', 'levanc@example.com', '0901234569', '789 Cach Mang Thang Tam, Ha Noi', 1995, 'Male');
INSERT INTO Tutor (UserID, Certifications, Experience, Subjects, AverageRating, NumOfCourses) VALUES
(1, 'TESOL, TEFL', '5 years teaching English', 'English', 4.5, 3),
(3, 'Bachelor of Mathematics', '3 years teaching Mathematics', 'Mathematics', 4.2, 2);
INSERT INTO Student (UserID, EnrolledCourses) VALUES
(2, 'English, Mathematics');
INSERT INTO Course (CourseName, CourseDescription, Capacity, MinimumStudents, TutorID) VALUES
('Advanced English', 'Advanced level English course for adults', 20, 5, 1),
('Intermediate Mathematics', 'Intermediate level Mathematics course for high school students', 25, 5, 3);
INSERT INTO Review (CourseID, StudentID, Rating, Comment) VALUES
(1, 2, 5, 'Excellent course with a very knowledgeable tutor'),
(2, 2, 4, 'Good course but needs more practical examples');
INSERT INTO Account (UserID, Username, AccPassword, AccRole) VALUES
(1, 'tutorA', 'passwordA', 'Tutor'),
(2, 'studentB', 'passwordB', 'Student'),
(3, 'tutorC', 'passwordC', 'Tutor');

