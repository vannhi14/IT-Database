create database TTHD4;
go
use TTHD4;

create table KHACHHANG
(
	MaKH char(5) PRIMARY KEY,
	HoTen varchar(30),
	DiaChi varchar(30),
	SoDT varchar(15),
	LoaiKH varchar(10)
)

create table BANG_DIA
(
	MaBD char(5) PRIMARY KEY,
	TenBD varchar(25),
	TheLoai varchar(25)
)

create table PHIEUTHUE
(
	MaPT char(5) PRIMARY KEY,
	MaKH char(5),
	NgayThue smalldatetime,
	NgayTra smalldatetime,
	Soluongthue int
)

create table CHITIET_PM
(
	MaPT char(5),
	MaBD char(5),
	constraint MaPT_MaBD PRIMARY KEY (MaPT, MaBD)
)

alter table PHIEUTHUE add
constraint PT_MaKH foreign key (MaKH) references KHACHHANG(MaKH)

alter table CHITIET_PM add
constraint CTPM_MaPT foreign key (MaPT) references PHIEUTHUE(MaPT),
constraint CTPM_MaBD foreign key (MaBD) references BANG_DIA(MaBD)
go

--2.1
alter table BANG_DIA add
constraint BD_TheLoai check (TheLoai in ('ca nhac', 'phim hanh dong', 'phim tinh cam', 'phim hoat hinh'))
go

--2.2
create trigger trg22
on PHIEUTHUE
for insert
as
	declare @MaKH char(5), @Soluongthue int, @LoaiKH varchar(10)
	select @MaKH = MaKH, @Soluongthue = Soluongthue
	from INSERTED 
	if (@Soluongthue > 5)
	begin 
		select @LoaiKH = KH.LoaiKH
		from INSERTED as I, KHACHHANG as KH
		where I.MaKH = KH.MaKH
		if (@LoaiKH <> 'VIP')
		begin
			print 'Loi: Khach hang khong thuoc VIP khong duoc thue qua 5 san pham'
			rollback transaction
		end
		else
		begin
			print 'Thanh cong!'
		end
	end
go

--3.1
select KH.MaKH, KH.HoTen 
from KHACHHANG as KH, PHIEUTHUE as PT, CHITIET_PM as CTPM, BANG_DIA as BD 
where KH.MaKH = PT.MaKH and PT.MaPT = CTPM.MaPT and CTPM.MaBD = BD.MaBD
and BD.TheLoai = 'phim tinh cam' and PT.Soluongthue = 3

--3.2
select top 1 with ties KH.MaKH, KH.HoTen 
from KHACHHANG as KH, PHIEUTHUE as PT
where KH.MaKH = PT.MaKH and KH.LoaiKH = 'VIP'
group by KH.MaKH, KH.HoTen
order by count(PT.MaPT) desc

--3.3
select BDA.TheLoai, KHA.HoTen, count(CTA.MaPT)
from BANG_DIA as BDA, PHIEUTHUE as PTA, CHITIET_PM as CTA, KHACHHANG as KHA
where KHA.MaKH = PTA.MaKH and PTA.MaPT = CTA.MaPT and CTA.MaBD = BDA.MaBD
group by BDA.TheLoai, KHA.HoTen
having count(CTA.MaPT) >= (
	select count(CTB.MaPT)
	from BANG_DIA as BDB, PHIEUTHUE as PTB, CHITIET_PM as CTB, KHACHHANG as KHB
	where KHB.MaKH = PTB.MaKH and PTB.MaPT = CTB.MaPT and CTB.MaBD = BDB.MaBD
	group by BDB.TheLoai, KHB.HoTen
	having BDA.TheLoai = BDB.TheLoai
)


