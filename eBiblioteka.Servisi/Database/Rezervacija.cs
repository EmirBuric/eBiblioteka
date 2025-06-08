using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class Rezervacija
{
    public int RezervacijaId { get; set; }

    public int? KnjigaId { get; set; }

    public int? KorisnikId { get; set; }

    public DateTime DatumRezervacije { get; set; }

    public DateTime? DatumVracanja { get; set; }

    public bool? Odobrena { get; set; }

    public virtual Knjiga? Knjiga { get; set; }

    public virtual Korisnik? Korisnik { get; set; }
}
