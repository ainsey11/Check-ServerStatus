
-- Selects all from table
select * from Disk_Space

-- alters col character limit
alter table disk_space
alter column Servername varchar (50)

--drops data from table
truncate table Disk_Space

--Create Table with columns
CREATE TABLE disk_space (
       ID INT IDENTITY(1,1) NOT NULL,
       SpaceFree Int NOT NULL,
	   Driveletter NvarChar(50) NOT NULL,
       Warning_State Int NOT NULL,
	   Error_State Int NOT NULL,
	   Servername NvarChar(50) NOT NULL,
       timestamp DATETIME2 NOT NULL,
       PRIMARY KEY (ID)
);

CREATE TABLE permissions (
    ID INT IDENTITY(1,1) NOT NULL,
    Folderpath NvarChar(max) NOT NULL,
	IdentityReference NvarChar(max) NOT NULL,
    AccessControlType NvarChar(max) NOT NULL,
	Isinherited NvarChar(max),
	Inheritanceflags NvarChar(max),
	PropagationFlags NvarChar(max),
	timestamp DATETIME2 NOT NULL,
    PRIMARY KEY (ID)
);

CREATE TABLE windows_updates (
    ID INT IDENTITY(1,1) NOT NULL,
	servernane nvarchar(max) NOT NULL,
	updatescount Int NOT NULL,
	timestamp DATETIME2 NOT NULL,
    PRIMARY KEY (ID)
);

--create index
create index diskspace
on disk_space (Driveletter,warning_state,Error_state,Servername) 

select * from permissions order by IdentityReference asc