create database BAITHI;
go 
use BAITHI;

create table NHACUNGCAP (
MANCC varchar(5) PRIMARY KEY,
TENCC varchar(25),
QUOCGIA varchar(25),
LOAINCC varchar(20),
)

create table DUOCPHAM (
MADP char(5) PRIMARY KEY,
TENDP varchar(25),
LOAIDP varchar(20),
GIA money,
)

create table PHIEUNHAP (
SOPN char(5) PRIMARY KEY,
NGNHAP smalldatetime,
MANCC varchar(5),
LOAINHAP varchar(20),
)

create table CTPN (
SOPN char(5),
MADP char(5),
SOLUONG int,
constraint SOPN_MADP PRIMARY KEY (SOPN, MADP),
)

alter table PHIEUNHAP add
constraint PN_MANCC foreign key (MANCC) references NHACUNGCAP(MANCC)

alter table CTPN add
constraint CTPN_SOPN foreign key (SOPN) references PHIEUNHAP(SOPN),
constraint CTPN_MADP foreign key (MADP) references DUOCPHAM(MADP)
go 

create trigger trg3
on DUOCPHAM
for insert
as
	declare @LOAIDP varchar(20), @GIA money
	select @LOAIDP = LOAIDP
	from INSERTED
	if (@LOAIDP = 'Siro')
	begin
		select @GIA = GIA
		from INSERTED 
		if (@GIA < 100)
		begin
		print 'Loi'
		rollback transaction
		end
		else
		begin
			print 'Thanh cong'
		end
	end
go

create trigger trg4
on PHIEUNHAP
for insert, update 
as
	declare @LOAINHAP varchar(20), @QUOCGIA varchar(25)
	select @LOAINHAP = LOAINHAP
	from INSERTED as I, NHACUNGCAP as NCC
	where I.MANCC = NCC.MANCC
	if (@LOAINHAP = 'Nhap Khau')
	begin
		select @QUOCGIA = @QUOCGIA
		from INSERTED
		if (@QUOCGIA = 'VIETNAM')
		begin
			print 'Loi'
			rollback transaction
		end
		else
		begin
			print 'Thanh cong'
		end
	end

select * from PHIEUNHAP
where YEAR(NGNHAP) = 2017 and MONTH(NGNHAP) = 12
order by NGNHAP asc

select top 1 with ties MADP from CTPN 
group by MADP
order by sum(SOLUONG) desc

select CTPN.MADP from PHIEUNHAP as PN, CTPN, NHACUNGCAP as NCC
where CTPN.SOPN = PN.SOPN and PN.MANCC = NCC.MANCC
and NCC.LOAINCC = 'Thuong xuyen'
except
select CTPN.MADP from PHIEUNHAP as PN, CTPN, NHACUNGCAP as NCC
where CTPN.SOPN = PN.SOPN and PN.MANCC = NCC.MANCC
and NCC.LOAINCC = 'Vang lai'

select NCC.MANCC from NHACUNGCAP as NCC, PHIEUNHAP as PN
where NCC.MANCC = PN.MANCC and YEAR(PN.NGNHAP) = 2017
and not exists (
	select * from DUOCPHAM as DP
	where DP.GIA > 100000
	and not exists (
		select * from CTPN
		where CTPN.MADP = DP.MADP
		and CTPN.SOPN = PN.SOPN)
)

--
SET DATEFORMAT DMY 

INSERT INTO NHACUNGCAP (MANCC,TENCC,QUOCGIA,LOAINCC) VALUES ('NCC01','Phuc Hung','Viet Nam','Thuong Xuyen')
INSERT INTO NHACUNGCAP (MANCC,TENCC,QUOCGIA,LOAINCC) VALUES ('NCC02','JBPharmaraceuticals','India','Vang lai')
INSERT INTO NHACUNGCAP (MANCC,TENCC,QUOCGIA,LOAINCC) VALUES ('NCC03','Sapharco','Singapore','Vang lai')

INSERT INTO DUOCPHAM (MADP, TENDP, LOAIDP, GIA) VALUES ('DP01', 'Thuoc ho PH', 'Siro', '120000')
INSERT INTO DUOCPHAM (MADP, TENDP, LOAIDP, GIA) VALUES ('DP02', 'Zecuf Herbal', 'Vien nen', '200000')
INSERT INTO DUOCPHAM (MADP, TENDP, LOAIDP, GIA) VALUES ('DP03', 'Cotrim', 'Vien sui', '80000')

INSERT INTO PHIEUNHAP (SOPN, NGNHAP, MANCC, LOAINHAP) VALUES ('00001', '22/11/2017', 'NCC01', 'Noi dia')
INSERT INTO PHIEUNHAP (SOPN, NGNHAP, MANCC, LOAINHAP) VALUES ('00002', '04/12/2017', 'NCC03', 'Nhap khau')
INSERT INTO PHIEUNHAP (SOPN, NGNHAP, MANCC, LOAINHAP) VALUES ('00003', '10/12/2017', 'NCC02', 'Nhap khau')

INSERT INTO CTPN (SOPN, MADP, SOLUONG) VALUES ('00001', 'DP01', 100)
INSERT INTO CTPN (SOPN, MADP, SOLUONG) VALUES ('00001', 'DP02', 200)
INSERT INTO CTPN (SOPN, MADP, SOLUONG) VALUES ('00003', 'DP03', 543)
--

		