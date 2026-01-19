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
	MAKH char(4),
	MANV char(4),
	TRIGIA int,
	constraint MAKHFK foreign key (MAKH) references KHACHHANG(MAKH),
	constraint MANV foreign key (MANV) references NHANVIEN(MANV),

)

create table CTHD 
(
	SOHD int,
	MASP char(4),
	SL int,
	constraint SOHD_MASP PRIMARY KEY (SOHD, MASP),
	constraint SOHDFK FOREIGN KEY (SOHD) references HOADON(SOHD),
	constraint MASPFK FOREIGN KEY (MASP) references SANPHAM(MASP),
)