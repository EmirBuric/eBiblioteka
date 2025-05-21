using eBiblioteka.Modeli.DTOs;
using eBiblioteka.Modeli.SearchObjects;
using eBiblioteka.Modeli.UpsertRequest;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace eBiblioteka.Servisi.Interfaces
{
    public interface IRecenzijaServis:ICRUDServis<RecenzijaDTO,RecenzijaSearchObject,RecenzijaUpsertRequest,RecenzijaUpsertRequest>
    {
        public Task Odbij(int id);
        public Task Prihvati(int id);
    }
}
