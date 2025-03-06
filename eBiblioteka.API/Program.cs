using eBiblioteka.API.Auth;
using eBiblioteka.Servisi.Database;
using eBiblioteka.Servisi.Interfaces;
using eBiblioteka.Servisi.Services;
using Mapster;
using Microsoft.AspNetCore.Authentication;
using Microsoft.EntityFrameworkCore;
using Microsoft.OpenApi.Models;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddTransient<IAutorServis, AutorServis>();
builder.Services.AddTransient<IUlogaServis, UlogaServis>();
builder.Services.AddTransient<ITipClanarineServis, TipClanarineServis>();
builder.Services.AddTransient<IZanrServis, ZanrServis>();
builder.Services.AddTransient<IKorisniciServis, KorisnikServis>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen(c => {
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


var connectionString = builder.Configuration.GetConnectionString("eBiblioteka");
builder.Services.AddDbContext<Db180105Context>(options=>
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

app.Run();
