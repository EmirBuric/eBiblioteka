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
using System.Security.Cryptography;
using System.Text;

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
builder.Services.AddHostedService<ProvjeriStatusClanarineServis>();

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

builder.Services.AddCors(options=>
{
    options.AddPolicy("AllowCORSOrigins", policy =>
    {
        policy.WithOrigins("http://localhost:60000")
        .AllowAnyHeader()
        .AllowAnyMethod();
    });
});


var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowCORSOrigins");

app.UseHttpsRedirection();

app.UseAuthorization();

app.MapControllers();

using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<Db180105Context>();
    if (context.Database.EnsureCreated())
    {
        context.Database.Migrate();

        if (!context.Zanrs.Any())
        {
            Console.WriteLine("Seed started");

            // --- Zanrovi ---
            var zanrovi = new List<Zanr>
            {
                new Zanr { Naziv = "Klasična književnost" },
                new Zanr { Naziv = "Savremena književnost" },
                new Zanr { Naziv = "Naučna fantastika" },
                new Zanr { Naziv = "Fantazija" },
                new Zanr { Naziv = "Misterija/Triler" },
                new Zanr { Naziv = "Biografija" },
                new Zanr { Naziv = "Istorija" },
                new Zanr { Naziv = "Filozofija" },
                new Zanr { Naziv = "Ljubavni roman" },
                new Zanr { Naziv = "Dječja književnost" }
            };
            context.Zanrs.AddRange(zanrovi);
            context.SaveChanges(); // Spremi prvo da dobiješ ID-jeve

            // --- Autori ---
            var autori = new List<Autor>
            {
                new Autor { Ime = "Ivo", Prezime = "Andrić", DatumRodjenja = new DateTime(1892, 10, 9), Biografija = "Jugoslovenski i bosanskohercegovački pisac, dobitnik Nobelove nagrade za književnost 1961. godine." },
                new Autor { Ime = "Meša", Prezime = "Selimović", DatumRodjenja = new DateTime(1910, 4, 26), Biografija = "Bosanskohercegovački pisac, jedan od najznačajnijih predstavnika jugoslovenske književnosti." },
                new Autor { Ime = "Branko", Prezime = "Ćopić", DatumRodjenja = new DateTime(1915, 1, 1), Biografija = "Bosanskohercegovački pisac poznat po djelima za djecu i mladež." },
                new Autor { Ime = "J.K.", Prezime = "Rowling", DatumRodjenja = new DateTime(1965, 7, 31), Biografija = "Britanska književnica, autorka serijala Harry Potter." },
                new Autor { Ime = "George", Prezime = "Orwell", DatumRodjenja = new DateTime(1903, 6, 25), Biografija = "Engleski novelist i esejista, poznat po djelima '1984' i 'Životinjska farma'." },
                new Autor { Ime = "Agatha", Prezime = "Christie", DatumRodjenja = new DateTime(1890, 9, 15), Biografija = "Engleska spisateljica detektivskih romana, jedna od najprodavanijih autora svih vremena." },
                new Autor { Ime = "Stephen", Prezime = "King", DatumRodjenja = new DateTime(1947, 9, 21), Biografija = "Američki pisac horora, nadnaravnog, suspensa, krimića i fantazije." },
                new Autor { Ime = "Isaac", Prezime = "Asimov", DatumRodjenja = new DateTime(1920, 1, 2), Biografija = "Američki pisac i profesor biohemije, poznat po djelima naučne fantastike." }
            };
            context.Autors.AddRange(autori);
            context.SaveChanges();

            // Dohvati žanrove po imenu da dobiješ njihove ID-jeve
            var klasicnaKnjizevnost = context.Zanrs.First(z => z.Naziv == "Klasična književnost");
            var savremenaKnjizevnost = context.Zanrs.First(z => z.Naziv == "Savremena književnost");
            var naucnaFantastika = context.Zanrs.First(z => z.Naziv == "Naučna fantastika");
            var fantazija = context.Zanrs.First(z => z.Naziv == "Fantazija");
            var misterija = context.Zanrs.First(z => z.Naziv == "Misterija/Triler");
            var djecjaKnjizevnost = context.Zanrs.First(z => z.Naziv == "Dječja književnost");

            // --- Knjige sa pravilnim ZanrId ---
            var knjige = new List<Knjiga>
            {
                new Knjiga { Naziv = "Na Drini ćuprija", KratkiOpis = "Historijski roman o životu na Drini kroz četiri stoljeća", GodinaIzdanja = 1945, ZanrId = klasicnaKnjizevnost.ZanrId, Kolicina = 5, Dostupna = true, KnjigaDana = true },
                new Knjiga { Naziv = "Derviš i smrt", KratkiOpis = "Roman o duhovnoj borbi derviša Ahmeda Nurudina", GodinaIzdanja = 1966, ZanrId = klasicnaKnjizevnost.ZanrId, Kolicina = 3, Dostupna = true, Preporuceno = true },
                new Knjiga { Naziv = "Ježeva kućica", KratkiOpis = "Zbirka pripovedaka za djecu", GodinaIzdanja = 1957, ZanrId = djecjaKnjizevnost.ZanrId, Kolicina = 8, Dostupna = true },
                new Knjiga { Naziv = "Harry Potter i Kamen mudraca", KratkiOpis = "Prvi roman iz serijala o mladom čarobnjaku", GodinaIzdanja = 1997, ZanrId = fantazija.ZanrId, Kolicina = 10, Dostupna = true, KnjigaDana = false, Preporuceno = true },
                new Knjiga { Naziv = "1984", KratkiOpis = "Distopijski roman o totalitarnom društvu", GodinaIzdanja = 1949, ZanrId = savremenaKnjizevnost.ZanrId, Kolicina = 4, Dostupna = true, Preporuceno = true },
                new Knjiga { Naziv = "Ubistvo u Orient ekspresu", KratkiOpis = "Klasični detektivski roman s Herkulom Poarotom", GodinaIzdanja = 1934, ZanrId = misterija.ZanrId, Kolicina = 6, Dostupna = true },
                new Knjiga { Naziv = "Carrie", KratkiOpis = "Horor roman o djevojci s telekinetičkim sposobnostima", GodinaIzdanja = 1974, ZanrId = misterija.ZanrId, Kolicina = 0, Dostupna = false },
                new Knjiga { Naziv = "Ja, robot", KratkiOpis = "Zbirka priča o robotima i umjetnoj inteligenciji", GodinaIzdanja = 1950, ZanrId = naucnaFantastika.ZanrId, Kolicina = 3, Dostupna = true }
            };
            context.Knjigas.AddRange(knjige);
            context.SaveChanges();

            // --- Uloge ---
            var uloge = new List<Uloga>
            {
                new Uloga { Naziv = "Admin" },
                new Uloga { Naziv = "Korisnik" }
            };
            context.Ulogas.AddRange(uloge);
            context.SaveChanges();

            // --- Tip članarine ---
            var tipClanarini = new List<TipClanarine>
            {
                new TipClanarine { VrijemeTrajanja = 1, Cijena = 10 },
                new TipClanarine { VrijemeTrajanja = 3, Cijena = 25 },
                new TipClanarine { VrijemeTrajanja = 6, Cijena = 45 },
                new TipClanarine { VrijemeTrajanja = 12, Cijena = 80 }
            };
            context.TipClanarines.AddRange(tipClanarini);
            context.SaveChanges();

            // --- Čitaonice ---
            var citaonice = new List<Citaonica>
            {
                new Citaonica { Naziv = "Glavna čitaonica" },
                new Citaonica { Naziv = "Mala čitaonica" }
            };
            context.Citaonicas.AddRange(citaonice);
            context.SaveChanges();

            // --- Korisnici ---
            string passwordAdmin = "admin";
            string passwordKorisnik = "korisnik";

            string salt1 = GenerateSalt();
            string hash1 = GenerateHash(salt1, passwordAdmin);

            string salt2 = GenerateSalt();
            string hash2 = GenerateHash(salt2, passwordKorisnik);

            var korisnici = new List<Korisnik>
            {
                new Korisnik { Ime = "Admin", Prezime = "Admin", Email = "admin.admin@email.com", KorisnickoIme = "admin", LozinkaHash = hash1, LozinkaSalt = salt1, Telefon = "062-123-456" },
                new Korisnik { Ime = "Korisnik", Prezime = "Korisnik", Email = "korisnik.korisnik@email.com", KorisnickoIme = "korisnik", LozinkaHash = hash2, LozinkaSalt = salt2, Telefon = "062-234-567" },
                new Korisnik { Ime = "Alen", Prezime = "Islamovic", Email = "alen.islamovic@email.com", KorisnickoIme = "alen", LozinkaHash = hash2, LozinkaSalt = salt2, Telefon = "063-345-678" },
                new Korisnik { Ime = "Zeljko", Prezime = "Bebek", Email = "zeljko.bebek@email.com", KorisnickoIme = "zeljko", LozinkaHash = hash2, LozinkaSalt = salt2, Telefon = "064-456-789" }
            };
            context.Korisniks.AddRange(korisnici);
            context.SaveChanges();

            var adminUloga = context.Ulogas.First(u => u.Naziv == "Admin");
            var korisnikUloga = context.Ulogas.First(u => u.Naziv == "Korisnik");

            var adminKorisnik = context.Korisniks.First(k => k.KorisnickoIme == "admin");
            var obicniKorisnik = context.Korisniks.First(k => k.KorisnickoIme == "korisnik");
            var alenKorisnik = context.Korisniks.First(k => k.KorisnickoIme == "alen");
            var zeljkoKorisnik = context.Korisniks.First(k => k.KorisnickoIme == "zeljko");

            // --- Korisničke uloge ---
            context.KorisnikUlogas.AddRange(
                new KorisnikUloga { KorisnikId = adminKorisnik.KorisnikId, UlogaId = adminUloga.UlogaId },
                new KorisnikUloga { KorisnikId = obicniKorisnik.KorisnikId, UlogaId = korisnikUloga.UlogaId },
                new KorisnikUloga { KorisnikId = alenKorisnik.KorisnikId, UlogaId = korisnikUloga.UlogaId },
                new KorisnikUloga { KorisnikId = zeljkoKorisnik.KorisnikId, UlogaId = korisnikUloga.UlogaId }
            );

            // --- Veze između knjiga i autora ---
            var ivoAndric = context.Autors.First(a => a.Prezime == "Andrić");
            var mesaSelimovic = context.Autors.First(a => a.Prezime == "Selimović");
            var brankoCopic = context.Autors.First(a => a.Prezime == "Ćopić");
            var jkRowling = context.Autors.First(a => a.Prezime == "Rowling");
            var georgeOrwell = context.Autors.First(a => a.Prezime == "Orwell");
            var agathaChristie = context.Autors.First(a => a.Prezime == "Christie");
            var stephenKing = context.Autors.First(a => a.Prezime == "King");
            var isaacAsimov = context.Autors.First(a => a.Prezime == "Asimov");

            var naDriniCuprija = context.Knjigas.First(k => k.Naziv == "Na Drini ćuprija");
            var dervisISmrt = context.Knjigas.First(k => k.Naziv == "Derviš i smrt");
            var jezevaKucica = context.Knjigas.First(k => k.Naziv == "Ježeva kućica");
            var harryPotter = context.Knjigas.First(k => k.Naziv == "Harry Potter i Kamen mudraca");
            var orwell1984 = context.Knjigas.First(k => k.Naziv == "1984");
            var orientEkspres = context.Knjigas.First(k => k.Naziv == "Ubistvo u Orient ekspresu");
            var carrie = context.Knjigas.First(k => k.Naziv == "Carrie");
            var jaRobot = context.Knjigas.First(k => k.Naziv == "Ja, robot");

            context.KnjigaAutors.AddRange(
                new KnjigaAutor { KnjigaId = naDriniCuprija.KnjigaId, AutorId = ivoAndric.AutorId },
                new KnjigaAutor { KnjigaId = dervisISmrt.KnjigaId, AutorId = mesaSelimovic.AutorId },
                new KnjigaAutor { KnjigaId = jezevaKucica.KnjigaId, AutorId = brankoCopic.AutorId },
                new KnjigaAutor { KnjigaId = harryPotter.KnjigaId, AutorId = jkRowling.AutorId },
                new KnjigaAutor { KnjigaId = orwell1984.KnjigaId, AutorId = georgeOrwell.AutorId },
                new KnjigaAutor { KnjigaId = orientEkspres.KnjigaId, AutorId = agathaChristie.AutorId },
                new KnjigaAutor { KnjigaId = carrie.KnjigaId, AutorId = stephenKing.AutorId },
                new KnjigaAutor { KnjigaId = jaRobot.KnjigaId, AutorId = isaacAsimov.AutorId }
            );

            var tipClanarine1 = context.TipClanarines.First(t => t.VrijemeTrajanja == 1);
            var tipClanarine3 = context.TipClanarines.First(t => t.VrijemeTrajanja == 3);

            // --- Članarine ---
            context.Clanarinas.AddRange(
                new Clanarina { StatusClanarine = true, DatumUplate = DateTime.Now.AddDays(-30), DatumIsteka = DateTime.Now.AddDays(30), KorisnikId = zeljkoKorisnik.KorisnikId, TipClanarineId = tipClanarine3.TipClanarineId },
                new Clanarina { StatusClanarine = true, DatumUplate = DateTime.Now.AddDays(-15), DatumIsteka = DateTime.Now.AddDays(75), KorisnikId = obicniKorisnik.KorisnikId, TipClanarineId = tipClanarine3.TipClanarineId },
                new Clanarina { StatusClanarine = false, DatumUplate = DateTime.Now.AddDays(-200), DatumIsteka = DateTime.Now.AddDays(-30), KorisnikId = alenKorisnik.KorisnikId, TipClanarineId = tipClanarine1.TipClanarineId }
            );

            // --- Rezervacije ---
            context.Rezervacijas.AddRange(
                new Rezervacija { KnjigaId = naDriniCuprija.KnjigaId, KorisnikId = zeljkoKorisnik.KorisnikId, DatumRezervacije = DateTime.Now.AddDays(-5), DatumVracanja = DateTime.Now.AddDays(9), Odobrena = null },
                new Rezervacija { KnjigaId = harryPotter.KnjigaId, KorisnikId = obicniKorisnik.KorisnikId, DatumRezervacije = DateTime.Now.AddDays(-2), DatumVracanja = DateTime.Now.AddDays(12), Odobrena = null },
                new Rezervacija { KnjigaId = orwell1984.KnjigaId, KorisnikId = alenKorisnik.KorisnikId, DatumRezervacije = DateTime.Now.AddDays(-1), Odobrena = null }
            );

            // --- Recenzije ---
            context.Recenzijas.AddRange(
                new Recenzija { Ocjena = 5, Opis = "Masterpiece! Obavezno čitanje za sve ljubitelje književnosti.", KnjigaId = naDriniCuprija.KnjigaId, KorisnikId = obicniKorisnik.KorisnikId, Odobrena = true, DatumRecenzije = DateTime.Now.AddDays(-10) },
                new Recenzija { Ocjena = 4, Opis = "Vrlo zanimljiva knjiga, preporučujem svima!", KnjigaId = harryPotter.KnjigaId, KorisnikId = obicniKorisnik.KorisnikId, Odobrena = true, DatumRecenzije = DateTime.Now.AddDays(-5) },
                new Recenzija { Ocjena = 5, Opis = "Klasik koji se mora pročitati. Orwell je genije!", KnjigaId = orwell1984.KnjigaId, KorisnikId = alenKorisnik.KorisnikId, Odobrena = null, DatumRecenzije = DateTime.Now.AddDays(-3) },
                new Recenzija { Ocjena = 3, Opis = "Okej knjiga, ali očekivao sam više.", KnjigaId = orientEkspres.KnjigaId, KorisnikId = obicniKorisnik.KorisnikId, Odobrena = false, DatumRecenzije = DateTime.Now.AddDays(-1) }
            );

            // --- Korisnik izabrane knjige ---
            context.KorisnikIzabranaKnjigas.AddRange(
                new KorisnikIzabranaKnjiga { KnjigaId = dervisISmrt.KnjigaId, KorisnikId = alenKorisnik.KorisnikId, IsChecked = true, DatumRezervacije = DateTime.Now.AddDays(-7), DatumVracanja = DateTime.Now.AddDays(7) },
                new KorisnikIzabranaKnjiga { KnjigaId = jaRobot.KnjigaId, KorisnikId = obicniKorisnik.KorisnikId, IsChecked = true, DatumRezervacije = DateTime.Now.AddDays(-3), DatumVracanja = DateTime.Now.AddDays(11) },
                new KorisnikIzabranaKnjiga { KnjigaId = jezevaKucica.KnjigaId, KorisnikId = obicniKorisnik.KorisnikId, IsChecked = true, DatumRezervacije = DateTime.Now, DatumVracanja = DateTime.Now.AddDays(14) }
            );

            context.SaveChanges();
            Console.WriteLine("Seed completed successfully!");
        }
    }
}

app.Run();

static string GenerateSalt()
{
    var byteArray = RNGCryptoServiceProvider.GetBytes(16);


    return Convert.ToBase64String(byteArray);
}

static string GenerateHash(string salt, string password)
{
    byte[] src = Convert.FromBase64String(salt);
    byte[] bytes = Encoding.Unicode.GetBytes(password);
    byte[] dst = new byte[src.Length + bytes.Length];

    System.Buffer.BlockCopy(src, 0, dst, 0, src.Length);
    System.Buffer.BlockCopy(bytes, 0, dst, src.Length, bytes.Length);

    HashAlgorithm algorithm = HashAlgorithm.Create("SHA1");
    byte[] inArray = algorithm.ComputeHash(dst);
    return Convert.ToBase64String(inArray);
}

