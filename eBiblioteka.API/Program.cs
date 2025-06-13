using eBiblioteka.API.Auth;
using eBiblioteka.API.BackgroundServisi;
using eBiblioteka.API.Filteri;
using eBiblioteka.Servisi.Database;
using eBiblioteka.Servisi.Interfaces;
using eBiblioteka.Servisi.Izvjestaji;
using eBiblioteka.Servisi.Recommender;
using eBiblioteka.Servisi.Services;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;
using RabbitMQ.Client;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddTransient<IAutorServis, AutorServis>();
builder.Services.AddTransient<IUlogaServis, UlogaServis>();
builder.Services.AddTransient<ITipClanarineServis, TipClanarineServis>();
builder.Services.AddTransient<IZanrServis, ZanrServis>();
builder.Services.AddTransient<IKorisniciServis, KorisnikServis>();
builder.Services.AddTransient<IKnjigaAutoriServis, KnjigaAutorServis>();
builder.Services.AddTransient<IKnjigaServis, KnjigaServis>();
builder.Services.AddTransient<IKorisnikIzabranaKnjigaServis, KorisnikIzabranaKnjigServis>();
builder.Services.AddTransient<IRezervacijaServis, RezervacijaServis>();
builder.Services.AddTransient<IRecenzijaServis, RecenzijaServis>();
builder.Services.AddTransient<ICitaonicaServis, CitaonicaServis>();
builder.Services.AddTransient<ITerminServis, TerminServis>();
builder.Services.AddTransient<IClanarinaServis, ClanarinaSerivis>();
builder.Services.AddHostedService<KreirajTerminServis>();
builder.Services.AddHostedService<ProvjeriJeLiTerminProsaoServis>();

builder.Services.AddScoped<IRecommenderServis,RecommenderServis>();
builder.Services.AddScoped<IIzvejstajServis,IzvjestajServis>();

builder.Services.AddHttpContextAccessor();


builder.Services.AddControllers(x =>
{
    x.Filters.Add<ExceptionFilter>();
});


// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c =>
{
    c.AddSecurityDefinition("basicAuth", new OpenApiSecurityScheme()
    {
        Type = SecuritySchemeType.Http,
        Scheme = "basic"
    });

    c.AddSecurityRequirement(new OpenApiSecurityRequirement()
    {
        {
            new OpenApiSecurityScheme
            {
                Reference= new OpenApiReference{Type=ReferenceType.SecurityScheme,Id="basicAuth"}
            },
            new string[]{}
        }
    });

});

var rabbitMqFactory = new ConnectionFactory() { HostName = builder.Configuration["RabbitMQ:HostName"] };
builder.Services.AddSingleton(rabbitMqFactory);

var connectionString = builder.Configuration.GetConnectionString("eBiblioteka");
builder.Services.AddDbContext<Db180105Context>(options =>
options.UseSqlServer(connectionString));

builder.Services.AddAuthentication("BasicAuthentication").
    AddScheme<AuthenticationSchemeOptions, BasicAuthenticationHandler>("BasicAuthentication", null);

builder.Services.AddMapster();


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

using (var scope=app.Services.CreateScope())
{
    var dataContext=scope.ServiceProvider.GetRequiredService<Db180105Context>();
    //dataContext.Database.EnsureCreated();

    dataContext.Database.Migrate();
}

app.Run();
