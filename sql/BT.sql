create database QLBH;
go
use QLBH;

create table KHACHHANG
( 
	MAKH char(4) PRIMARY KEY,
	HOTEN varchar(30),
	DCHI varchar(50),
	SODT varchar(20),
	NGSINH smalldatetime,
	NGDK smalldatetime,
	DOANHSO money,
)

create table NHANVIEN
( 
	MANV char(4) PRIMARY KEY,
	HOTEN varchar(30),
	SODT varchar(20),
	NGVL smalldatetime,
)

create table SANPHAM
(
	MASP char(4) PRIMARY KEY,
	TENSP varchar(30),
	DVT varchar(20),
	NUOCSX varchar(30),
	GIA int,
)

create table HOADON
(
	SOHD int PRIMARY KEY,
	NGHD smalldatetime,
	MAKH char(4) foreign key (MAKH) references KHACHHANG(MAKH),
	MANV char(4) foreign key (MANV) references NHANVIEN(MANV),
	TRIGIA int,
)

create table CTHD 
(
	SOHD int foreign key (SOHD) references HOADON(SOHD),
	MASP char(4) foreign key (MASP) references SANPHAM(MASP),
	SL int,
)