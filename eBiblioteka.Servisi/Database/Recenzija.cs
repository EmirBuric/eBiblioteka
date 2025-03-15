using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class Recenzija
{
    public int RecenzijaId { get; set; }

    public int? Ocjena { get; set; }

    public string? Opis { get; set; }

    public int? KnjigaId { get; set; }

    public int? KorisnikId { get; set; }

    public bool? Odobrena { get; set; }

    public DateTime DatumRecenzije { get; set; }

    public virtual Knjiga? Knjiga { get; set; }

    public virtual Korisnik? Korisnik { get; set; }
}
