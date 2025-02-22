using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace eBiblioteka.Servisi.Migrations
{
    /// <inheritdoc />
    public partial class InitialCreate : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Autor",
                columns: table => new
                {
                    AutorId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Ime = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Prezime = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    DatumRodjenja = table.Column<DateOnly>(type: "date", nullable: true),
                    Biografija = table.Column<string>(type: "nvarchar(max)", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Autor__F58AE929771A00DC", x => x.AutorId);
                });

            migrationBuilder.CreateTable(
                name: "Citaonica",
                columns: table => new
                {
                    CitaonicaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Citaonic__2AF2F8E5364443F1", x => x.CitaonicaId);
                });

            migrationBuilder.CreateTable(
                name: "Korisnik",
                columns: table => new
                {
                    KorisnikId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Ime = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Prezime = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    Telefon = table.Column<string>(type: "nvarchar(15)", maxLength: 15, nullable: true),
                    KorisnickoIme = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    LozinkaHash = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                    LozinkaSalt = table.Column<string>(type: "nvarchar(256)", maxLength: 256, nullable: false),
                    IsBanned = table.Column<bool>(type: "bit", nullable: true, defaultValue: false),
                    DatumBanovanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Korisnik__80B06D4145F9C87E", x => x.KorisnikId);
                });

            migrationBuilder.CreateTable(
                name: "TipClanarine",
                columns: table => new
                {
                    TipClanarineId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    VrijemeTrajanja = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__TipClana__3414671F2F0B31B5", x => x.TipClanarineId);
                });

            migrationBuilder.CreateTable(
                name: "Uloga",
                columns: table => new
                {
                    UlogaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Uloga__DCAB23CBD74FA940", x => x.UlogaId);
                });

            migrationBuilder.CreateTable(
                name: "Zanr",
                columns: table => new
                {
                    ZanrId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Zanr__953868D3F1CE1602", x => x.ZanrId);
                });

            migrationBuilder.CreateTable(
                name: "Termin",
                columns: table => new
                {
                    TerminId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Datum = table.Column<DateOnly>(type: "date", nullable: false),
                    Start = table.Column<TimeOnly>(type: "time", nullable: false),
                    Kraj = table.Column<TimeOnly>(type: "time", nullable: false),
                    KorisnikId = table.Column<int>(type: "int", nullable: true),
                    JeRezervisan = table.Column<bool>(type: "bit", nullable: true, defaultValue: false),
                    CitaonicaId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Termin__42126C95E3021893", x => x.TerminId);
                    table.ForeignKey(
                        name: "FK__Termin__Citaonic__619B8048",
                        column: x => x.CitaonicaId,
                        principalTable: "Citaonica",
                        principalColumn: "CitaonicaId");
                    table.ForeignKey(
                        name: "FK__Termin__Korisnik__5FB337D6",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                });

            migrationBuilder.CreateTable(
                name: "Clanarina",
                columns: table => new
                {
                    ClanarinaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StatusClanarine = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    DatumUplate = table.Column<DateTime>(type: "datetime", nullable: false),
                    DatumIsteka = table.Column<DateTime>(type: "datetime", nullable: false),
                    KorisnikId = table.Column<int>(type: "int", nullable: true),
                    TipClanarineId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Clanarin__C51E3B97DF546AA2", x => x.ClanarinaId);
                    table.ForeignKey(
                        name: "FK__Clanarina__Koris__66603565",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__Clanarina__TipCl__6754599E",
                        column: x => x.TipClanarineId,
                        principalTable: "TipClanarine",
                        principalColumn: "TipClanarineId");
                });

            migrationBuilder.CreateTable(
                name: "KorisnikUloga",
                columns: table => new
                {
                    KorisnikUlogaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KorisnikId = table.Column<int>(type: "int", nullable: true),
                    UlogaId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Korisnik__1608726EB57EC12B", x => x.KorisnikUlogaId);
                    table.ForeignKey(
                        name: "FK__KorisnikU__Koris__4F7CD00D",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                    table.ForeignKey(
                        name: "FK__KorisnikU__Uloga__5070F446",
                        column: x => x.UlogaId,
                        principalTable: "Uloga",
                        principalColumn: "UlogaId");
                });

            migrationBuilder.CreateTable(
                name: "Knjiga",
                columns: table => new
                {
                    KnjigaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Naziv = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    KratkiOpis = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    GodinaIzdanja = table.Column<int>(type: "int", nullable: true),
                    Slika = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    ZanrId = table.Column<int>(type: "int", nullable: true),
                    IsDeleted = table.Column<bool>(type: "bit", nullable: true, defaultValue: false),
                    VrijemeBrisanja = table.Column<DateTime>(type: "datetime", nullable: true),
                    Kolicina = table.Column<int>(type: "int", nullable: false),
                    Dostupna = table.Column<bool>(type: "bit", nullable: true, defaultValue: true),
                    KnjigaDana = table.Column<bool>(type: "bit", nullable: true, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Knjiga__4A1281F337C344CF", x => x.KnjigaId);
                    table.ForeignKey(
                        name: "FK__Knjiga__ZanrId__3B75D760",
                        column: x => x.ZanrId,
                        principalTable: "Zanr",
                        principalColumn: "ZanrId");
                });

            migrationBuilder.CreateTable(
                name: "KnjigaAutor",
                columns: table => new
                {
                    KnjigaAutorId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KnjigaId = table.Column<int>(type: "int", nullable: true),
                    AutorId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__KnjigaAu__7CCCDDD631B6011C", x => x.KnjigaAutorId);
                    table.ForeignKey(
                        name: "FK__KnjigaAut__Autor__4222D4EF",
                        column: x => x.AutorId,
                        principalTable: "Autor",
                        principalColumn: "AutorId");
                    table.ForeignKey(
                        name: "FK__KnjigaAut__Knjig__412EB0B6",
                        column: x => x.KnjigaId,
                        principalTable: "Knjiga",
                        principalColumn: "KnjigaId");
                });

            migrationBuilder.CreateTable(
                name: "KorisnikIzabranaKnjiga",
                columns: table => new
                {
                    KorisnikIzabranaKnjigaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KnjigaId = table.Column<int>(type: "int", nullable: true),
                    KorisnikId = table.Column<int>(type: "int", nullable: true),
                    IsChecked = table.Column<bool>(type: "bit", nullable: true, defaultValue: false),
                    DatumRezervacije = table.Column<DateTime>(type: "datetime", nullable: true),
                    DatumVracanja = table.Column<DateTime>(type: "datetime", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Korisnik__08384791156793EB", x => x.KorisnikIzabranaKnjigaId);
                    table.ForeignKey(
                        name: "FK__KorisnikI__Knjig__59063A47",
                        column: x => x.KnjigaId,
                        principalTable: "Knjiga",
                        principalColumn: "KnjigaId");
                    table.ForeignKey(
                        name: "FK__KorisnikI__Koris__59FA5E80",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                });

            migrationBuilder.CreateTable(
                name: "Recenzija",
                columns: table => new
                {
                    RecenzijaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Ocjena = table.Column<int>(type: "int", nullable: true),
                    Opis = table.Column<string>(type: "nvarchar(max)", nullable: true),
                    KnjigaId = table.Column<int>(type: "int", nullable: true),
                    KorisnikId = table.Column<int>(type: "int", nullable: true),
                    Odobrena = table.Column<bool>(type: "bit", nullable: true, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Recenzij__D36C607006F2FA35", x => x.RecenzijaId);
                    table.ForeignKey(
                        name: "FK__Recenzija__Knjig__48CFD27E",
                        column: x => x.KnjigaId,
                        principalTable: "Knjiga",
                        principalColumn: "KnjigaId");
                    table.ForeignKey(
                        name: "FK__Recenzija__Koris__49C3F6B7",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                });

            migrationBuilder.CreateTable(
                name: "Rezervacija",
                columns: table => new
                {
                    RezervacijaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    KnjigaId = table.Column<int>(type: "int", nullable: true),
                    KorisnikId = table.Column<int>(type: "int", nullable: true),
                    DatumRezervacije = table.Column<DateTime>(type: "datetime", nullable: false),
                    DatumVracanja = table.Column<DateTime>(type: "datetime", nullable: true),
                    Odobrena = table.Column<bool>(type: "bit", nullable: true, defaultValue: false),
                    Pregledana = table.Column<bool>(type: "bit", nullable: true, defaultValue: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK__Rezervac__CABA44DDB80F2209", x => x.RezervacijaId);
                    table.ForeignKey(
                        name: "FK__Rezervaci__Knjig__534D60F1",
                        column: x => x.KnjigaId,
                        principalTable: "Knjiga",
                        principalColumn: "KnjigaId");
                    table.ForeignKey(
                        name: "FK__Rezervaci__Koris__5441852A",
                        column: x => x.KorisnikId,
                        principalTable: "Korisnik",
                        principalColumn: "KorisnikId");
                });

            migrationBuilder.CreateIndex(
                name: "IX_Clanarina_KorisnikId",
                table: "Clanarina",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Clanarina_TipClanarineId",
                table: "Clanarina",
                column: "TipClanarineId");

            migrationBuilder.CreateIndex(
                name: "IX_Knjiga_ZanrId",
                table: "Knjiga",
                column: "ZanrId");

            migrationBuilder.CreateIndex(
                name: "IX_KnjigaAutor_AutorId",
                table: "KnjigaAutor",
                column: "AutorId");

            migrationBuilder.CreateIndex(
                name: "IX_KnjigaAutor_KnjigaId",
                table: "KnjigaAutor",
                column: "KnjigaId");

            migrationBuilder.CreateIndex(
                name: "IX_KorisnikIzabranaKnjiga_KnjigaId",
                table: "KorisnikIzabranaKnjiga",
                column: "KnjigaId");

            migrationBuilder.CreateIndex(
                name: "IX_KorisnikIzabranaKnjiga_KorisnikId",
                table: "KorisnikIzabranaKnjiga",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_KorisnikUloga_KorisnikId",
                table: "KorisnikUloga",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_KorisnikUloga_UlogaId",
                table: "KorisnikUloga",
                column: "UlogaId");

            migrationBuilder.CreateIndex(
                name: "IX_Recenzija_KnjigaId",
                table: "Recenzija",
                column: "KnjigaId");

            migrationBuilder.CreateIndex(
                name: "IX_Recenzija_KorisnikId",
                table: "Recenzija",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Rezervacija_KnjigaId",
                table: "Rezervacija",
                column: "KnjigaId");

            migrationBuilder.CreateIndex(
                name: "IX_Rezervacija_KorisnikId",
                table: "Rezervacija",
                column: "KorisnikId");

            migrationBuilder.CreateIndex(
                name: "IX_Termin_CitaonicaId",
                table: "Termin",
                column: "CitaonicaId");

            migrationBuilder.CreateIndex(
                name: "IX_Termin_KorisnikId",
                table: "Termin",
                column: "KorisnikId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "Clanarina");

            migrationBuilder.DropTable(
                name: "KnjigaAutor");

            migrationBuilder.DropTable(
                name: "KorisnikIzabranaKnjiga");

            migrationBuilder.DropTable(
                name: "KorisnikUloga");

            migrationBuilder.DropTable(
                name: "Recenzija");

            migrationBuilder.DropTable(
                name: "Rezervacija");

            migrationBuilder.DropTable(
                name: "Termin");

            migrationBuilder.DropTable(
                name: "TipClanarine");

            migrationBuilder.DropTable(
                name: "Autor");

            migrationBuilder.DropTable(
                name: "Uloga");

            migrationBuilder.DropTable(
                name: "Knjiga");

            migrationBuilder.DropTable(
                name: "Citaonica");

            migrationBuilder.DropTable(
                name: "Korisnik");

            migrationBuilder.DropTable(
                name: "Zanr");
        }
    }
}
