using System.Text.Json;

namespace FineCollectionService.Controllers;

[ApiController]
[Route("")]
public class CollectionController : ControllerBase
{
    private static string? _fineCalculatorLicenseKey = null;
    private readonly ILogger<CollectionController> _logger;
    private readonly IFineCalculator _fineCalculator;
    private readonly VehicleRegistrationService _vehicleRegistrationService;

    public CollectionController(IConfiguration config, ILogger<CollectionController> logger,
        IFineCalculator fineCalculator, VehicleRegistrationService vehicleRegistrationService,
        DaprClient daprClient)
    {
        _logger = logger;
        _fineCalculator = fineCalculator;
        _vehicleRegistrationService = vehicleRegistrationService;

        // set finecalculator component license-key
        if (_fineCalculatorLicenseKey == null)
        {
            //_fineCalculatorLicenseKey = config.GetValue<string>("fineCalculatorLicenseKey");
            var secrets = daprClient.GetSecretAsync("dapr-workshop-secrets", "finecalculator").Result;
            _fineCalculatorLicenseKey = secrets["licensekey"];
        }
    }

    [Topic("pubsub", "speedingviolations")]
    [Route("collectfine")]
    [HttpPost()]
    //public async Task<ActionResult> CollectFine(SpeedingViolation speedingViolation)
    public async Task<ActionResult> CollectFine(
        SpeedingViolation speedingViolation,
        /*[FromBody] JsonDocument cloudevent*/
        [FromServices] DaprClient daprClient)
    {
        // manual parsing of cloudevent
        /*
        var data = cloudevent.RootElement.GetProperty("data");
        var speedingViolation = new SpeedingViolation
        {
            VehicleId = data.GetProperty("vehicleId").GetString()!,
            RoadId = data.GetProperty("roadId").GetString()!,
            Timestamp = data.GetProperty("timestamp").GetDateTime()!,
            ViolationInKmh = data.GetProperty("violationInKmh").GetInt32()
        };
        */
        _logger.LogInformation("Processing speeding violation message");

        decimal fine = _fineCalculator.CalculateFine(_fineCalculatorLicenseKey!, speedingViolation.ViolationInKmh);

        // get owner info
        var vehicleInfo = await _vehicleRegistrationService.GetVehicleInfo(speedingViolation.VehicleId);

        // log fine
        string fineString = fine == 0 ? "tbd by the prosecutor" : $"{fine} Euro";
        _logger.LogInformation($"Sent speeding ticket to {vehicleInfo.OwnerName}. " +
            $"Road: {speedingViolation.RoadId}, Licensenumber: {speedingViolation.VehicleId}, " +
            $"Vehicle: {vehicleInfo.Brand} {vehicleInfo.Model}, " +
            $"Violation: {speedingViolation.ViolationInKmh} Km/h, Fine: {fineString}, " +
            $"On: {speedingViolation.Timestamp.ToString("dd-MM-yyyy")} " +
            $"at {speedingViolation.Timestamp.ToString("hh:mm:ss")}.");

        // send fine by email
        var body = EmailUtils.CreateEmailBody(speedingViolation, vehicleInfo, fineString);
        var metadata = new Dictionary<string, string>
        {
            ["emailFrom"] = "noreply@cfca.gov",
            ["emailTo"] = vehicleInfo.OwnerEmail,
            ["subject"] = $"Speeding violation on the {speedingViolation.RoadId}"
        };

        // send email via output binding
        await daprClient.InvokeBindingAsync("sendmail", "create", body, metadata);


        return Ok();
    }


    // Manually create dapr/subscribe endpoint
    /*
    [Route("/dapr/subscribe")]
    [HttpGet()]
    public object Subscribe()
    {
        _logger.LogInformation("Received subscribe request");
        return new object[]
        {
            new
            {
                pubsubname = "pubsub",
                topic = "speedingviolations",
                route = "/collectfine"
            }
        };
    }
    */
}