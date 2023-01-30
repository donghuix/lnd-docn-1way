function cities = GetCities()

ind = [3;4;13;14;18;23;25;26];
cities = struct([]);
cities(1).Name = 'Kolkata';   cities(1).X = 88.3639;  cities(1).Y = 22.5726;
cities(2).Name = 'Mumbai';    cities(2).X = 72.8777;  cities(2).Y = 19.0760;
cities(3).Name = 'Dhaka';     cities(3).X = 90.4125;  cities(3).Y = 23.8103;
cities(4).Name = 'Guangzhou'; cities(4).X = 113.2644; cities(4).Y = 23.1291;
cities(5).Name = 'Ho Chi Minh City'; cities(5).X = 106.6297; cities(5).Y = 10.8231;
cities(6).Name = 'Shanghai'; cities(6).X = 121.4737; cities(6).Y = 31.2304;
cities(7).Name = 'Bangkok'; cities(7).X = 100.5018; cities(7).Y = 13.7563;
cities(8).Name = 'Rangoon'; cities(8).X = 96.1735; cities(8).Y = 16.8409;
cities(9).Name = 'Miami'; cities(9).X = -80.1918; cities(9).Y = 25.7617;
cities(10).Name = 'Hai Phòng'; cities(10).X = 106.6881; cities(10).Y = 20.8449;
cities(11).Name = 'Alexandria'; cities(11).X = 29.9187; cities(11).Y = 31.2001;
% cities(12).Name = 'Tianjin'; cities(12).X = 117.1994; cities(12).Y = 39.0851;
cities(12).Name = 'London'; cities(12).X = -0.1276; cities(12).Y = 51.5072;
cities(13).Name = 'Khulna'; cities(13).X = 89.5403; cities(13).Y = 22.8456;
cities(14).Name = 'Ningbo'; cities(14).X = 121.5440; cities(14).Y = 29.8683;
%cities(15).Name = 'Lagos'; cities(15).X = 3.3792; cities(15).Y = 6.5244;
cities(15).Name = 'Hamburg'; cities(15).X = 9.9872; cities(15).Y = 53.5488;
cities(16).Name = 'Abidjan'; cities(16).X = -4.0083; cities(16).Y = 5.3600;
cities(17).Name = 'New York'; cities(17).X = -74.0060; cities(17).Y = 40.7128;
cities(18).Name = 'Chittagong'; cities(18).X = 91.7832; cities(18).Y = 22.3569;
cities(19).Name = 'Tokyo'; cities(19).X = 139.6503; cities(19).Y = 35.6762;
cities(20).Name = 'Jakarta'; cities(20).X = 106.8456; cities(20).Y = -6.2088;
cities(21).Name = 'Hong Kong'; cities(21).X = 114.1694; cities(21).Y = 22.3193;
cities(22).Name = 'New Orleans'; cities(22).X = -90.0715; cities(22).Y = 29.9511;
cities(23).Name = 'Osaka-Kobe'; cities(23).X = 135.5023; cities(23).Y = 34.6937;
cities(24).Name = 'Amsterdam'; cities(24).X = 4.9041; cities(24).Y = 52.3676;
cities(25).Name = 'Rotterdam'; cities(25).X = 4.4777; cities(25).Y = 51.9244;
cities(26).Name = 'Nagoya'; cities(26).X = 136.9066; cities(26).Y = 35.1815;
cities(27).Name = 'Qingdao'; cities(27).X = 120.3830; cities(27).Y = 36.0662;
cities(28).Name = 'Virginia Beach'; cities(28).X = -75.9792; cities(28).Y = 36.8516;

cities(ind) = [];
end

