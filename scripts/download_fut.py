import cdsapi

c = cdsapi.Client()

for i in range(2040,2051):
    c.retrieve(
        'sis-water-level-change-timeseries-cmip6',
        {
            'variable': 'total_water_level',
            'experiment': 'future',
            'model': [
                'CMCC-CM2-VHR4', 'EC-Earth3P-HR', 'GFDL-CM4C192-SST',
                'HadGEM3-GC31-HM', 'HadGEM3-GC31-HM-SST',
            ],
            'temporal_aggregation': '10_min',
            'year': str(i),
            'month': [
                '01', '02', '03',
                '04', '05', '06',
                '07', '08', '09',
                '10', '11', '12',
            ],
            'format': 'zip',
        },
        'download_' + str(i) + '.zip')