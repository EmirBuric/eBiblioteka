using eBiblioteka.Modeli;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi
{
    public interface IAutorServis:ICRUDServis<Autor,AutorSearchObject,AutorUpsertRequest,AutorUpsertRequest>
    {
    }
}
