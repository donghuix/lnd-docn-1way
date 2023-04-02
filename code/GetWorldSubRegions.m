function SubR = GetWorldSubRegions(catogory,ax)


if catogory == 1
    subregions = ...
    {'South America','Western Africa','Central America','Eastern Africa','Northern Africa', ...
     'Middle Africa','Southern Africa','Northern America','Caribbean','Eastern Asia',       ...
     'Southern Asia','Southeastern Asia','Southern Europe','Austria and New Zealand',       ...
     'Melanesia','Micronesia','Polynesia','Central Asia','Western Asia','Eastern Europe',   ...
     'Northern Europe','Western Europe'};
   
    UN_Code = [5;11;13;14;15;17;18;21;29;30;34;35;39;53;54;57;61;143;145;151;154;155];
    cols = jet(length(UN_Code));

    S = shaperead('~/Downloads/TM_WORLD_BORDERS_SIMPL-0.3/TM_WORLD_BORDERS_SIMPL-0.3.shp');
    sub = [S(:).SUBREGION];
    SubR = struct();
    
    for j = 1 : length(UN_Code)
        SubR(j).Name = subregions(j);
        SubR(j).X    = [];
        SubR(j).Y    = [];
        for i = 1 : length(S)
            if sub(i) == UN_Code(j)
                SubR(j).X = [SubR(j).X; S(i).X'];
                SubR(j).Y = [SubR(j).Y; S(i).Y'];
                %plot(S(i).X,S(i).Y,'-','Color',cols(j,:),'LineWidth',1); hold on;
            end
        end
    end
elseif catogory == 2
    SubR(1).Name  = 'Australia';
    SubR(1).Acr   = 'AUS';
    SubR(1).X     = [+110 +155];
    SubR(1).Y     = [-45  -11 ]; 
    
    SubR(2).Name  = 'Amazon Basin';
    SubR(2).Acr   = 'AMZ';
    SubR(2).Y     = [-20 +12]; 
    SubR(2).X     = [-82 -34];
    
    SubR(3).Name  = 'Southern South America';
    SubR(3).Acr   = 'SSA';
    SubR(3).Y     = [-56 -20];
    SubR(3).X     = [-76 -40];
    
    SubR(4).Name  = 'Central America';
    SubR(4).Acr   = 'CAM';
    SubR(4).Y     = [+10  +30];
    SubR(4).X     = [-116 -85];%[-116 -83];
    
    SubR(5).Name  = 'Western North America';
    SubR(5).Acr   = 'WNA';
    SubR(5).Y     = [+30  +60 ];
    SubR(5).X     = [-130 -103];
    
    SubR(6).Name  = 'Eastern North America';
    SubR(6).Acr   = 'ENA';
    SubR(6).Y     = [+25 +50];
    SubR(6).X     = [-85 -60];
    
    SubR(7).Name  = 'Alaska';
    SubR(7).Acr   = 'ALA';
    SubR(7).Y     = [+50  +72 ];%[+60  +72];
    SubR(7).X     = [-170 -150];%[-170 -103];
    
    SubR(8).Name  = 'Greenland';
    SubR(8).Acr   = 'GRL';
    SubR(8).Y     = [+50  +85];
    SubR(8).X     = [-103 -10];
    
    SubR(9).Name  = 'Mediterranean Basin';
    SubR(9).Acr   = 'MED';
    SubR(9).Y     = [+30 +48];
    SubR(9).X     = [-10 +40];
    
    SubR(10).Name  = 'Northern Europe';
    SubR(10).Acr   = 'NEU';
    SubR(10).Y     = [+48 +75];
    SubR(10).X     = [-10 +40];
    
    SubR(11).Name  = 'Western Africa';
    SubR(11).Acr   = 'WAF';
    SubR(11).Y     = [-12 +18];
    SubR(11).X     = [-20 +22];
    
    SubR(12).Name  = 'Eastern Africa';
    SubR(12).Acr   = 'EAF';
    SubR(12).Y     = [-12 +18];
    SubR(12).X     = [+22 +52];

    SubR(13).Name  = 'Southern Africa';
    SubR(13).Acr   = 'SAF';
    SubR(13).Y     = [-35 -12];
    SubR(13).X     = [-10 +52];
    
    SubR(14).Name  = 'Sahara';
    SubR(14).Acr   = 'SAH';
    SubR(14).Y     = [+18 +30];
    SubR(14).X     = [-20 +65];
    
    SubR(15).Name  = 'Southeast Asia';
    SubR(15).Acr   = 'SEA';
    SubR(15).Y     = [-11  +20 ];
    SubR(15).X     = [+100 +155]; %[+95 +155];
    
    SubR(16).Name  = 'East Asia';
    SubR(16).Acr   = 'EAS';
    SubR(16).Y     = [+20  +50 ];
    SubR(16).X     = [+100 +145];
    
    SubR(17).Name  = 'South Asia';
    SubR(17).Acr   = 'SAS';
    SubR(17).Y     = [+5  +30 ];
    SubR(17).X     = [+65 +100];
    
    SubR(18).Name  = 'Central Asia';
    SubR(18).Acr   = 'CAS';
    SubR(18).Y     = [+30 +50];
    SubR(18).X     = [+40 +75];
    
    SubR(19).Name  = 'North Asia';
    SubR(19).Acr   = 'NAS';
    SubR(19).Y     = [+50 +80 ];
    SubR(19).X     = [+40 +180];
    
    SubR([8 14 18]) = [];
    
    cols = jet(length(SubR));
    for i = 1 : length(SubR)
        xmin = SubR(i).X(1); xmax = SubR(i).X(2);
        ymin = SubR(i).Y(1); ymax = SubR(i).Y(2);
        SubR(i).X = [xmin xmax xmax xmin xmin];
        SubR(i).Y = [ymin ymin ymax ymax ymin];
        if nargin > 1 && ~isempty(ax)
        %plot(ax,SubR(i).X,SubR(i).Y,'-','Color',cols(i,:),'LineWidth',1); hold on;
        plot(ax,SubR(i).X,SubR(i).Y,'k-','LineWidth',1); hold on;
        end
    end

%     load coastlines.mat;
%     plot(coastlon,coastlat,'k-','LineWidth',1)
end
%     for i = 1 : length(S)
%         if sub(i) == 5
%             % South America
%             plot(S(i).X,S(i).Y,'r-','LineWidth',2); hold on;
%         elseif sub(i) == 11 || sub(i) == 14 || sub(i) == 15 || sub(i) == 17 || sub(i) == 18
%             % Afica
%             plot(S(i).X,S(i).Y,'k-','LineWidth',2); hold on;
%         elseif sub(i) == 13
%             % Central America
%         elseif sub(i) == 21
%             % Northern America
%              plot(S(i).X,S(i).Y,'b-','LineWidth',2); hold on;
%         elseif sub(i) == 30
%             % Eastern Asia
%              plot(S(i).X,S(i).Y,'g-','LineWidth',2); hold on;
%         elseif sub(i) == 34
%             % Southern Asia
%              plot(S(i).X,S(i).Y,'m-','LineWidth',2); hold on;
%         elseif sub(i) == 143
%             % Central Asia
%         elseif sub(i) == 35
%             % Southeastern Asia
%         elseif sub(i) == 39 || sub(i) == 154 ||  sub(i) == 155
%             % Europe
%             plot(S(i).X,S(i).Y,'c-','LineWidth',2); hold on;
%         elseif sub(i) == 53
%             % Austria
%             plot(S(i).X,S(i).Y,'y-','LineWidth',2); hold on;
%         end
%     end
end