using eBiblioteka.Servisi.Database;
using eBiblioteka.Servisi.Interfaces;
using eBiblioteka.Servisi.Services;
using Mapster;
using Microsoft.EntityFrameworkCore;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.

builder.Services.AddTransient<IAutorServis, AutorServis>();
builder.Services.AddTransient<IUlogaServis, UlogaServis>();
builder.Services.AddTransient<ITipClanarineServis, TipClanarineServis>();
builder.Services.AddTransient<IZanrServis, ZanrServis>();

builder.Services.AddControllers();
// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var connectionString = builder.Configuration.GetConnectionString("eBiblioteka");
builder.Services.AddDbContext<Db180105Context>(options=>
options.UseSqlServer(connectionString));

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
