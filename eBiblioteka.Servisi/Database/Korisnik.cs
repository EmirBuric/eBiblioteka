using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class Korisnik
{
    public int KorisnikId { get; set; }

    public string Ime { get; set; } = null!;

    public string Prezime { get; set; } = null!;

    public string Email { get; set; } = null!;

    public string? Telefon { get; set; }

    public string KorisnickoIme { get; set; } = null!;

    public string LozinkaHash { get; set; } = null!;

    public string LozinkaSalt { get; set; } = null!;

    public bool? IsBanned { get; set; }

    public DateTime? DatumBanovanja { get; set; }

    public virtual ICollection<Clanarina> Clanarinas { get; set; } = new List<Clanarina>();

    public virtual ICollection<KorisnikIzabranaKnjiga> KorisnikIzabranaKnjigas { get; set; } = new List<KorisnikIzabranaKnjiga>();

    public virtual ICollection<KorisnikUloga> KorisnikUlogas { get; set; } = new List<KorisnikUloga>();

    public virtual ICollection<Recenzija> Recenzijas { get; set; } = new List<Recenzija>();

    public virtual ICollection<Rezervacija> Rezervacijas { get; set; } = new List<Rezervacija>();

    public virtual ICollection<Termin> Termins { get; set; } = new List<Termin>();
}
