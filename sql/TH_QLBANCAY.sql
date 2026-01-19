create database QLBANCAY;
go
use QLBANCAY;

create table KHACHHANG(
MAKH char(5) PRIMARY KEY,
TENKH varchar(25),
DIACHI varchar(20),
LOAIKH varchar(20),
)

create table LOAICAY (
MALC char(5) PRIMARY KEY,
TENLC varchar(25),
XUATXU varchar(20),
GIA money
)

create table HOADON (
SOHD char(5) PRIMARY KEY,
NGHD smalldatetime,
MAKH char(5),
KHUYENMAI int
)

create table CTHD (
SOHD char(5),
MALC char(5),
SOLUONG int
constraint SOHD_MALC PRIMARY KEY (SOHD, MALC)
)

alter table HOADON add
constraint HD_MAKH foreign key (MAKH) references KHACHHANG(MAKH)

alter table CTHD add
constraint CTHD_SOHD foreign key (SOHD) references CTHD(SOHD),
constraint CTHD_MALC foreign key (MALC) references CTHD(MALC)
go

create trigger trg3 
on LOAICAY
for insert, update
as
	declare @XUATXU varchar(20), @GIA money
	select @XUATXU = XUATXU
	from INSERTED
	if(@XUATXU = 'Anh')
	begin 
		select @GIA = GIA
		from INSERTED
		if(@GIA < 250000)
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
on CTHD
for update 
as
	declare @SOLUONG int
	select @SOLUONG = SOLUONG 
	from INSERTED as I, HOADON as HD
	where I.SOHD = HD.SOHD 
	if (@SOLUONG > 5)
	begin 
	update HOADON
	set KHUYENMAI = KHUYENMAI + 10
	print 'Da cap nhat khuyen mai'
	end

select * from HOADON
where YEAR(NGHD) = 2017 and MONTH(NGHD) >= 10 and MONTH(NGDH) <= 12
order by KHUYENMAI asc

select top 1 with ties CTHD.MALC from CTHD, HOADON as HD
where CTHD.SOHD = HD.SOHD and MONTH(HD.NGHD) = 12
group by CTHD.MALC
order by sum(CTHD.SOLUONG) asc

select CTHD.MALC from CTHD, HOADON as HD, KHACHHANG as KH
where CTHD.SOHD = HD.SOHD and HD.MAKH = KH.MAKH
and KH.LOAIKH = 'Thuong xuyen'
intersect
select CTHD.MALC from CTHD, HOADON as HD, KHACHHANG as KH
where CTHD.SOHD = HD.SOHD and HD.MAKH = KH.MAKH
and KH.LOAIKH = 'Vang lai'

select KH.MAKH from KHACHHANG as KH, HOADON as HD
where KH.MAKH = HD.MAKH
and not exists (
	select * from LOAICAY as LC
	where not exists (
		select * from CTHD
		where CTHD.MALC = LC.MALC
		and CTHD.SOHD = HD.SOHD
)






