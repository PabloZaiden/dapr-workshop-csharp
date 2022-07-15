// create web-app
var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<IFineCalculator, HardCodedFineCalculator>();

builder.Services.AddDaprClient(builder => builder
    .UseHttpEndpoint("http://localhost:3601")
    .UseGrpcEndpoint("http://localhost:60001"));

// DI needed for VehicleRegistrationService
//builder.Services.AddHttpClient();
//builder.Services.AddSingleton<VehicleRegistrationService>();

// DI needed for VehicleRegistrationService (using Dapr)
builder.Services.AddSingleton<VehicleRegistrationService>(_ => 
    new VehicleRegistrationService(DaprClient.CreateInvokeHttpClient("vehicleregistrationservice", "http://localhost:3601")));

var mvcBuilder = builder.Services.AddControllers();

// add dapr integration in mvc controllers
mvcBuilder.AddDapr();

var app = builder.Build();

// configure web-app
if (app.Environment.IsDevelopment())
{
    app.UseDeveloperExceptionPage();
}

// configure routing
app.MapControllers();

// unwrap the cloudevents messages sent by dapr pubsub
app.UseCloudEvents();

// add the well-known Dapr endpoints and respond based on the Actions decorated with [Topic]
app.MapSubscribeHandler();

// let's go!
app.Run("http://localhost:6001");
