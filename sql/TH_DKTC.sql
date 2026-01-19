create database DKTC;
go
use DKTC;

create table SINHVIEN (
MASV char(10) PRIMARY KEY,
HOTEN varchar(25),
NAMSINH smalldatetime,
MACN char(10),
)

create table CHUYENNGANH (
MACN char(10) PRIMARY KEY,
TENCN varchar(25),
)

create table DANGKY (
MASV char(10),
MAMON varchar(10),
NAMHOC smalldatetime,
HOCKY int,
)

create table MON (
MAMON varchar(10) PRIMARY KEY,
TENMON varchar(20),
SOTINCHI int,
MACN char(10),
)

alter table SINHVIEN add
constraint SV_MACN foreign key (MACN) references CHUYENNGANH(MACN)

alter table DANGKY add
constraint DK_MASV foreign key (MASV) references SINHVIEN(MASV),
constraint DK_MAMON foreign key (MAMON) references MON(MAMON)

alter table MON add
constraint M_MACN foreign key (MACN) references CHUYENNGANH(MACN)
go

alter table MON add
constraint M_TINCHI check (SOTINCHI >= 2 and SOTINCHI <= 4)
go

create trigger trg22
on DANGKY
for insert, update
as
	declare @NAMSINH smalldatetime, @NAMHOC smalldatetime
	select @NAMSINH = NAMSINH, @NAMHOC = NAMHOC
	from INSERTED as I, SINHVIEN as SV
	where I.MASV = SV.MASV
	if (@NAMSINH > @NAMHOC)
	begin 
		print 'Khong hop le'
		rollback transaction
	end
	else
	begin
		print 'Thanh cong'
	end
--
select SV.MASV, SV.HOTEN from SINHVIEN as SV, CHUYENNGANH as CN
where SV.MACN = CN.MACN and CN.TENCN = 'HE THONG THONG TIN'
--
select SV.MASV, SV.HOTEN from SINHVIEN as SV, CHUYENNGANH as CN
where SV.MACN = CN.MACN and CN.TENCN = 'HE THONG THONG TIN'
except 
select SV.MASV, SV.HOTEN from SINHVIEN as SV, CHUYENNGANH as CN
where SV.MACN = CN.MACN and CN.MACN = 'PTTKHTTT'
--
select SV.MASV, SV.HOTEN from SINHVIEN as SV
where not exists (
	select * from CHUYENNGANH as CN, MON as M
	where CN.MACN = M.MACN and CN.TENCN = 'HE THONG THONG TIN' 
	and not exists (
		select * from DANGKY as DK
		where SV.MASV = DK.MASV
		and DK.MAMON = M.MAMON
		)
	)
--
select SV.MASV, SV.HOTEN from SINHVIEN as SV
where not exists (
	select * from MON as M, CHUYENNGANH as CN
	where CN.MACN = M.MACN and CN.MACN = SV.MASV 
	and not exists (
		select * from DANGKY as DK
		where SV.MASV = DK.MASV
		and DK.MAMON = M.MAMON
		)
	)

select top 1 with ties CN.TENCN from CHUYENNGANH as CN, DANGKY as DK, MON as M
where CN.MACN = M.MACN and M.MAMON = DK.MAMON
group by CN.TENCN
order by count(DK.MASV) desc
