create database THHK;
go
use THHK;

---

create table PHONGBAN
(
	MAPHG varchar(2) PRIMARY KEY,
	TENPHG varchar(50),
	TRPHG varchar(3),
	NGNC smalldatetime
)

create table NHANVIEN 
(
	MANV varchar(3) PRIMARY KEY,
	HOTEN varchar(40),
	NGSINH smalldatetime,
	PHAI varchar(3),
	DIACHI varchar(50),
	MAPHG varchar(2),
	LUONG money
)

create table DEAN 
(
	MADA varchar(5) PRIMARY KEY,
	TENDA varchar(50),
	DDIEM_DA varchar(50),
	MAPHG varchar(2),
	NGBD_DK smalldatetime,
	NGKT_DK smalldatetime
)

create table PHANCONG
(
	MANV varchar(3),
	MADA varchar(5),
	THOIGIAN int,
	constraint MANV_MADA PRIMARY KEY (MANV, MADA)
)

alter table PHONGBAN add
constraint PB_TRPHG foreign key (TRPHG) references NHANVIEN(MANV)

alter table NHANVIEN add
constraint NV_MAPHG foreign key (MAPHG) references PHONGBAN(MAPHG)

alter table DEAN add
constraint DA_MAPHG foreign key (MAPHG) references PHONGBAN(MAPHG)

alter table PHANCONG add
constraint PC_MANV foreign key (MANV) references NHANVIEN(MANV),
constraint PC_MADA foreign key (MADA) references DEAN(MADA)