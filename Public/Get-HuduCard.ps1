function Get-HuduCard {
	Param (
        [Parameter(Mandatory=$true)]    
        [String]$integration_slug = '',
		[String]$integration_id = '',
		[String]$integration_identifier =''
	
	)
	
	if ($id) {
		$Article = Invoke-HuduRequest -Method get -Resource "/api/v1/articles/$id"
		return $Article
	} else {

		$resourcefilter = "&integration_slug=$($integration_slug)"

		if ($integration_id) {
			$resourcefilter = "$($resourcefilter)&integration_id=$($integration_id)"
		}

		if ($name) {
			$resourcefilter = "$($resourcefilter)&integration_identifier=$($integration_identifier)"
		}
	
		$i = 1;
		$AllCards = do {
			$Cards = Invoke-HuduRequest -Method get -Resource "/api/v1/cards/lookup?page=$i&page_size=1000$($resourcefilter)"
			$i++
			$Cards.Cards
		} while ($Cards.Cards.count % 1000 -eq 0 -and $Cards.Cards.count -ne 0)
		
	
		return $AllCards
	
	}
}
