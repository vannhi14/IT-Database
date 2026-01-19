create database QLHV;
go 
use QLHV;

create table HOCVIEN
(
	MAHV char(5) PRIMARY KEY,
	HO varchar(40),
	TEN varchar(10),
	NGSINH smalldatetime,
	GIOITINH varchar(3),
	NOISINH varchar(40),
	MALOP char(3),
)

create table GIAOVIEN
(
	MAGV char(4) PRIMARY KEY,
	HOTEN varchar(40),
	HOCVI varchar(10),
	HOCHAM varchar(10),
	GIOITINH varchar(3),
	NGSINH smalldatetime,
	NGVL smalldatetime,
	HESO numeric(4,2),
	MUCLUONG money,
	MAKHOA varchar(4),
)

create table KHOA
(
	MAKHOA varchar(4) PRIMARY KEY,
	TENKHOA varchar(40),
	NGTLAP smalldatetime,
	TRGKHOA char(4),
)

create table LOP 
(
	MALOP char(3) PRIMARY KEY,
	TENLOP varchar(40),
	TRGLOP char(5),
	SISO tinyint,
	MAGVCN char(4),
)

create table MONHOC 
(
	MAMH varchar(10) PRIMARY KEY,
	TENMH varchar(40),
	TCLT tinyint,
	TCTH tinyint,
	MAKHOA varchar(4),
)

create table DIEUKIEN 
(
	MAMH varchar(10),
	MAMH_TRUOC varchar(10),
)

create table GIANGDAY 
(
	MALOP char(3),
	MAMH varchar(10),
	MAGV char(4),
	HOCKY tinyint,
	NAM smallint,
	TUNGAY smalldatetime,
	DENNGAY smalldatetime,
)

create table KETQUATHI
(
	MAHV char(5),
	MAMH varchar(10),
	LANTHI tinyint,
	NGTHI smalldatetime,
	DIEM numeric(4,2),
	KQUA varchar(10),
)

alter table HOCVIEN add
constraint HV_MALOP foreign key (MALOP) references LOP(MALOP)

alter table GIAOVIEN add
constraint GV_MAKHOA foreign key (MAKHOA) references KHOA(MAKHOA)

alter table KHOA add
constraint KHOA_MAKHOA foreign key (MAKHOA) references KHOA(MAKHOA)

alter table LOP add
constraint LOP_TRGLOP foreign key (TRGLOP) references HOCVIEN(MAHV),
constraint LOP_MAGVCN foreign key (MAGVCN) references GIAOVIEN(MAGV)

alter table MONHOC add
constraint MH_MAKHOA foreign key (MAKHOA) references KHOA(MAKHOA)

alter table DIEUKIEN add
constraint DK_MAMH foreign key (MAMH) references MONHOC(MAMH),
constraint DK_MAMHTRC foreign key (MAMH_TRUOC) references MONHOC(MAMH)

alter table GIANGDAY add
constraint GD_MALOP foreign key (MALOP) references LOP(MALOP),
constraint GD_MAMH foreign key (MAMH) references MONHOC(MAMH),
constraint GD_MAGV foreign key (MAGV) references GIAOVIEN(MAGV)

alter table KETQUATHI add
constraint KQ_MAHV foreign key (MAHV) references HOCVIEN(MAHV),
constraint KQ_MAMH foreign key (MAMH) references MONHOC(MAMH)
