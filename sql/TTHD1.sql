create database TTHD1;
go
use TTHD1;
create table TACGIA
( 
	MaTG char(5) PRIMARY KEY,
	HoTen varchar(20),
	DiaChi varchar(50),
	NgSinh smalldatetime,
	SoDT varchar(15)
)
create table SACH
(
	MaSach char(5) PRIMARY KEY,
	TenSach varchar(25),
	TheLoai varchar(25)
)
create table TACGIA_SACH
(
	MaTG char(5),
	MaSach char(5),
	constraint MaTG_MaSach PRIMARY KEY (MaTG, MaSach)
)
create table PHATHANH
(
	MaPH char(5) PRIMARY KEY,
	MaSach char(5),
	NgayPH smalldatetime,
	SoLuong int,
	NhaXuatBan varchar(20)
)

alter table TACGIA_SACH add
constraint TGS_MaTG foreign key (MaTG) references TACGIA(MaTG),
constraint TGS_MaSach foreign key (MaSach) references SACH(MaSach)

alter table PHATHANH add
constraint PH_MaSach foreign key (MaSach) references SACH(MaSach)
go

--2.1
create trigger trg21
on PHATHANH
for insert, update
as
	declare @NgayPH smalldatetime, @NgSinh smalldatetime
	select @NgayPH = NgayPH, @NgSinh = NgSinh
	from INSERTED as I, TACGIA as TG, TACGIA_SACH as TGS
	where I.MaSach = TGS.MaSach and TGS.MaTG = TG.MaTG
	if (@NgayPH < @NgSinh)
	begin
		print 'Loi: Ngay phat hanh khong hop le'
		rollback transaction
	end
	else 
	begin
		print 'Thanh cong!'
	end
go

--2.2
create trigger trg22
on PHATHANH
for insert, update
as
		declare  @NhaXuatBan varchar(20), @MaSach char(5), @TheLoai varchar(25)
		select @MaSach = MaSach, @NhaXuatBan = NhaXuatBan
		from INSERTED
		if (@NhaXuatBan <> 'Giao Duc')
		begin 
			select @TheLoai = TheLoai
			from INSERTED as I, SACH as S
			where I.MaSach = S.MaSach
			if (@TheLoai = 'Giao Khoa')
			begin
				print 'Loi: Sach Giao Khoa phai do NXB Giao Duc phat hanh'
				rollback transaction
			end
			else
			begin
				print 'Thanh cong!'
			end

--3.1
select TG.MaTG, TG.HoTen, TG.SoDT 
from TACGIA as TG, TACGIA_SACH as TGS, SACH as S, PHATHANH as PH
where TG.MaTG = TGS.MaTG and TGS.MaSach = S.MaSach and S.MaSach = PH.MaSach
and S.TheLoai = 'Van hoc' and PH.NhaXuatBan = 'NXB Tre'

--3.2
select top 1 with ties PH.NhaXuatBan 
from SACH as S, PHATHANH as PH
where S.MaSach = PH.MaSach 
group by PH.NhaXuatBan
order by count(S.TheLoai) desc

--3.3
select NhaXuatBan, TACGIA.MaTG, TACGIA.HoTen, count(MaPH)
from TACGIA, PHATHANH PHA, TACGIA_SACH
where TACGIA.MaTG = TACGIA_SACH.MaTG and TACGIA_SACH.MaSach = PHA.MaSach
group by NHAXUATBAN, TACGIA.MaTG, TACGIA.HoTen
having count(MAPH) >= (
	select count(MAPH) 
	from TACGIA, PHATHANH PHB, TACGIA_SACH
	where TACGIA.MaTG = TACGIA_SACH.MaTG and TACGIA_SACH.MaSach = PHB.MaSach
	group by NHAXUATBAN, TACGIA.MaTG
	having PHB.NhaXuatBan = PHA.NhaXuatBan
)

