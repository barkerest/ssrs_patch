ALTER PROCEDURE [dbo].[UpdateSubscription]
	@id uniqueidentifier,
	@Locale nvarchar(260),
	@OwnerSid varbinary(85) = NULL,
	@OwnerName nvarchar(260),
	@OwnerAuthType int,
	@DeliveryExtension nvarchar(260) = NULL,
	@InactiveFlags int,
	@ExtensionSettings ntext = NULL,
	@ModifiedBySid varbinary(85) = NULL, 
	@ModifiedByName nvarchar(260),
	@ModifiedByAuthType int,
	@ModifiedDate datetime,
	@Description nvarchar(512) = NULL,
	@LastStatus nvarchar(260) = NULL,
	@EventType nvarchar(260),
	@MatchData ntext = NULL,
	@Parameters ntext = NULL,
	@DataSettings ntext = NULL,
	@Version int
AS
BEGIN
	-- Update a subscription's information.
	DECLARE @ModifiedByID uniqueidentifier
	DECLARE @OwnerID uniqueidentifier

	EXEC GetUserID @ModifiedBySid, @ModifiedByName, @ModifiedByAuthType, @ModifiedByID OUTPUT
	EXEC GetUserID @OwnerSid, @OwnerName, @OwnerAuthType, @OwnerID OUTPUT

	-- Lookup the comment for the report.
	DECLARE @Comment VARCHAR(512)
	SELECT
		@Comment=T.ParamValue
	FROM
		(SELECT
			P.value('(./Name)[1]', 'NVARCHAR(100)') AS [ParamName],
			P.value('(./Value)[1]', 'NVARCHAR(512)') AS [ParamValue]
		FROM
			(SELECT CAST(@ExtensionSettings AS XML) X) S
		CROSS APPLY
			S.X.nodes('/ParameterValues/ParameterValue') x(P)
		) T
	WHERE
		T.ParamName='Comment'

	SELECT @Description=ISNULL(@Comment,@Description)

	-- Make sure there is a valid provider
	update Subscriptions set
			[DeliveryExtension] = @DeliveryExtension,
			[Locale] = @Locale,
			[OwnerID] = @OwnerID,
			[InactiveFlags] = @InactiveFlags,
			[ExtensionSettings] = @ExtensionSettings,
			[ModifiedByID] = @ModifiedByID,
			[ModifiedDate] = @ModifiedDate,
			[Description] = @Description,
			[LastStatus] = @LastStatus,
			[EventType] = @EventType,
			[MatchData] = @MatchData,
			[Parameters] = @Parameters,
			[DataSettings] = @DataSettings,
		[Version] = @Version
	where
		[SubscriptionID] = @id
END
