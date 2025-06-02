using System;
using System.Collections.Generic;

namespace eBiblioteka.Servisi.Database;

public partial class Termin
{
    public int TerminId { get; set; }

    public DateOnly Datum { get; set; }

    public TimeOnly Start { get; set; }

    public TimeOnly Kraj { get; set; }

    public int? KorisnikId { get; set; }

    public bool? JeRezervisan { get; set; }

    public bool JeProsao { get; set; }

    public int? CitaonicaId { get; set; }

    public virtual Citaonica? Citaonica { get; set; }

    public virtual Korisnik? Korisnik { get; set; }
}
