-- I'm sure it's not the most efficient method, but it works.
SELECT
	T.SubscriptionID,
	T.ParamValue AS [Comment]
FROM (SELECT
		S.SubscriptionID,
		P.value('(./Name)[1]', 'NVARCHAR(100)') AS [ParamName],
		P.value('(./Value)[1]','NVARCHAR(MAX)') AS [ParamValue]
	FROM
		(SELECT
			SubscriptionID
			,CAST([ExtensionSettings] AS XML) AS [ExtensionSettingsXML]
		FROM
			Subscriptions) S
	CROSS APPLY
		S.ExtensionSettingsXML.nodes('/ParameterValues/ParameterValue') x(P)
	) T
WHERE
	T.ParamName='Comment'
