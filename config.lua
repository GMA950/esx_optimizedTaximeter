Config = {}

-- The currency prefix to be used
Config.CurrencyPrefix = '$'


-- Distance Measurement -- valid options are "mi" or "km". "mi" is default. If you
-- change this be sure to change RateSuffix as well
Config.DistanceMeasurement = 'km'

-- Rate Suffix
Config.RateSuffix = '/km'

-- Which vehicles can not use the meter (if RestrictVehicles= true). By default
-- Bicycles, OffRoad and Emergency vehicles are disallowed
Config.DisallowedVehicleClasses = {8, 9, 18}


Config.Base = '005.00' --10.00
Config.Rate = 5 --15
Config.RateType = 'distance' --'flat' es la otra opcion
Config.OnStop = 0.033 --0.5

Config.AuthorizedVehicles = {

	{
		model = 'taxi',
		label = 'Taxi'
	},
	{
		model = 'taxi4',
		label = 'Taxi Classic'
	},
	{
		model = 'taxi3',
		label = 'Taxi Prius'
	},
	{
		model = 'stretch',
		label = 'Limusina'
	},
	{
		model = 'airbus',
		label = 'MicroBus'
	},

}