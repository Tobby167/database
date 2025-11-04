CREATE database picture;
USE picture;
CREATE table picture(id int, image longblob);

desc table pictures;

                    
insert into picture (id, image) values
					(1, load_file('C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\WIN_20250406_18_23_59_Pro.jpg'));                    
select * from picture;
