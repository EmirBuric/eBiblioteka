using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class Knjiga
{
    public int KnjigaId { get; set; }

    public string Naziv { get; set; } = null!;

    public string? KratkiOpis { get; set; }

    public int? GodinaIzdanja { get; set; }

    public byte[]? Slika { get; set; }

    public int? ZanrId { get; set; }

    public bool? IsDeleted { get; set; }

    public DateTime? VrijemeBrisanja { get; set; }

    public int Kolicina { get; set; }

    public bool? Dostupna { get; set; }

    public bool? KnjigaDana { get; set; }

    public bool? Preporuceno { get; set; }

    public virtual ICollection<KnjigaAutor> KnjigaAutors { get; set; } = new List<KnjigaAutor>();

    public virtual ICollection<KorisnikIzabranaKnjiga> KorisnikIzabranaKnjigas { get; set; } = new List<KorisnikIzabranaKnjiga>();

    public virtual ICollection<Recenzija> Recenzijas { get; set; } = new List<Recenzija>();

    public virtual ICollection<Rezervacija> Rezervacijas { get; set; } = new List<Rezervacija>();

    public virtual Zanr? Zanr { get; set; }
}
