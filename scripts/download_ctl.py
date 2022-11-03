import cdsapi

c = cdsapi.Client()

''' 'model': [
                'CMCC-CM2-VHR4', 'EC-Earth3P-HR', 'GFDL-CM4C192-SST',
                'HadGEM3-GC31-HM', 'HadGEM3-GC31-HM-SST',
            ],'''

for i in range(1951,2015):
    c.retrieve(
        'sis-water-level-change-timeseries-cmip6',
        {
            'format': 'zip',
            'experiment': 'historical',
            'model': 'GFDL-CM4C192-SST',
            'temporal_aggregation': '10_min',
            'year': str(i),
            'month': [
                '01', '02', '03',
                '04', '05', '06',
                '07', '08', '09',
                '10', '11', '12',
            ],
            'variable': 'total_water_level',
        },
        'download_' + str(i) + '.zip')